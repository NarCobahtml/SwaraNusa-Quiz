import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:swaranusaquiz/app/data/models/backend_models.dart';
import 'package:swaranusaquiz/app/data/providers/firestore_paths.dart';

class AuthRepository {
  AuthRepository({auth.FirebaseAuth? firebaseAuth})
    : _auth = firebaseAuth ?? auth.FirebaseAuth.instance;

  final auth.FirebaseAuth _auth;
  Future<void>? _googleInitializeFuture;

  auth.User? get currentUser => _auth.currentUser;
  Stream<auth.User?> authStateChanges() => _auth.authStateChanges();

  Future<auth.UserCredential> signIn({
    required String email,
    required String password,
  }) => _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<auth.UserCredential> register({
    required String email,
    required String password,
  }) => _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<auth.UserCredential> signInWithGoogle() async {
    // google_sign_in v7: singleton instance, must initialize first
    await (_googleInitializeFuture ??= GoogleSignIn.instance.initialize());

    final googleUser = await GoogleSignIn.instance.authenticate();
    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw auth.FirebaseAuthException(
        code: 'missing-google-id-token',
        message: 'Google tidak mengembalikan ID token.',
      );
    }

    final credential = auth.GoogleAuthProvider.credential(idToken: idToken);
    return _auth.signInWithCredential(credential);
  }

  Future<auth.UserCredential> signInWithFacebook() {
    final provider = auth.FacebookAuthProvider()
      ..addScope('email')
      ..addScope('public_profile');
    return _auth.signInWithProvider(provider);
  }

  Future<void> signOut() => _auth.signOut();
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);
}

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<AppUser?> currentUserProfile(String uid) async {
    final snapshot = await _firestore.doc(FirestorePaths.user(uid)).get();
    if (!snapshot.exists) return null;
    return AppUser.fromSnapshot(snapshot);
  }

  Stream<AppUser?> watchUser(String uid) {
    return _firestore.doc(FirestorePaths.user(uid)).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return AppUser.fromSnapshot(snapshot);
    });
  }

  Future<Map<String, dynamic>?> getDailyLoginData(String uid) async {
    final snapshot = await _firestore
        .doc(FirestorePaths.userDailyLogin(uid))
        .get();
    return snapshot.data();
  }

  /// Fetch achievement yang dimiliki user, digabung dengan detail dari koleksi master.
  Future<List<Map<String, dynamic>>> getUserBadgesWithDetails(
    String uid,
  ) async {
    final userBadgesSnap = await _firestore
        .collection(FirestorePaths.userAchievements(uid))
        .get();
    if (userBadgesSnap.docs.isEmpty) return [];

    final ownedIds = userBadgesSnap.docs.map((d) => d.id).toList();

    final results = <Map<String, dynamic>>[];
    for (final badgeId in ownedIds) {
      final badgeSnap = await _firestore
          .doc('${FirestorePaths.achievements}/$badgeId')
          .get();
      if (badgeSnap.exists) {
        results.add({'id': badgeId, ...?badgeSnap.data()});
      } else {
        results.add({
          'id': badgeId,
          'name': badgeId,
          'stars': 1,
          'iconUrl': '',
        });
      }
    }
    return results;
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null && name.isNotEmpty) updates['name'] = name;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      updates['avatarUrl'] = avatarUrl;
    }
    await _firestore.doc(FirestorePaths.user(uid)).update(updates);
  }

  Future<void> createProfileIfMissing({
    required String uid,
    required String email,
    required String name,
    required String username,
  }) async {
    final ref = _firestore.doc(FirestorePaths.user(uid));
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (snapshot.exists) return;

      transaction.set(
        ref,
        AppUser(
          uid: uid,
          name: name,
          username: username,
          email: email,
          avatarUrl: 'assets/image/user_profile.png',
          level: 1,
          xp: 0,
          coin: 0,
          quizCompleted: 0,
          correctAnswerCount: 0,
          wrongAnswerCount: 0,
          badgesEarned: 1,
          isDarkMode: true,
        ).toCreateMap(),
      );
      transaction.set(_firestore.doc(FirestorePaths.userDailyLogin(uid)), {
        'currentStreak': 0,
        'lastLoginDate': '',
        'claimedToday': false,
        'totalLoginDays': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.set(
        _firestore.doc(FirestorePaths.userBadge(uid, 'account_created')),
        {'earnedAt': FieldValue.serverTimestamp()},
      );
    });
  }
}

class ContentRepository {
  ContentRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<QuizModeDoc>> loadModes() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.quizModes)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();
    return snapshot.docs.map(QuizModeDoc.fromSnapshot).toList();
  }

  Future<List<LevelDoc>> loadLevels(String modeId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.levels)
        .where('modeId', isEqualTo: modeId)
        .orderBy('levelNumber')
        .get();
    return snapshot.docs.map(LevelDoc.fromSnapshot).toList();
  }

  Future<List<QuestionDoc>> loadQuestions(String levelId) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.questions)
        .where('levelId', isEqualTo: levelId)
        .where('isActive', isEqualTo: true)
        .get();
    final docs = snapshot.docs.map(QuestionDoc.fromSnapshot).toList();
    docs.sort((a, b) => a.questionNumber.compareTo(b.questionNumber));
    return docs;
  }

  Future<List<InstrumentDoc>> loadInstruments() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.instruments)
        .where('isActive', isEqualTo: true)
        .get();
    final docs = snapshot.docs.map(InstrumentDoc.fromSnapshot).toList();
    docs.sort((a, b) => a.name.compareTo(b.name));
    return docs;
  }

  Future<List<MissionDoc>> loadMissions() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.missions)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.map(MissionDoc.fromSnapshot).toList();
  }

  Future<List<BadgeDoc>> loadBadges() async {
    final snapshot = await _firestore
        .collection(FirestorePaths.achievements)
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.map(BadgeDoc.fromSnapshot).toList();
  }

  Future<List<LeaderboardEntryDoc>> loadLeaderboard({
    String periodKey = 'global',
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.users)
        .orderBy('xp', descending: true)
        .limit(limit)
        .get();
    final docs = snapshot.docs
        .where((doc) => !doc.id.startsWith('_'))
        .map(_leaderboardEntryFromUserSnapshot)
        .toList();
    return [
      for (var i = 0; i < docs.length; i++)
        LeaderboardEntryDoc(
          uid: docs[i].uid,
          rank: i + 1,
          name: docs[i].name,
          username: docs[i].username,
          avatarUrl: docs[i].avatarUrl,
          level: docs[i].level,
          xp: docs[i].xp,
          score: docs[i].score,
          quizCompleted: docs[i].quizCompleted,
        ),
    ];
  }

  Stream<List<LeaderboardEntryDoc>> watchLeaderboard({
    String periodKey = 'global',
    int limit = 50,
  }) {
    return _firestore
        .collection(FirestorePaths.users)
        .orderBy('xp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .where((doc) => !doc.id.startsWith('_'))
              .map(_leaderboardEntryFromUserSnapshot)
              .toList();
          return [
            for (var i = 0; i < docs.length; i++)
              LeaderboardEntryDoc(
                uid: docs[i].uid,
                rank: i + 1,
                name: docs[i].name,
                username: docs[i].username,
                avatarUrl: docs[i].avatarUrl,
                level: docs[i].level,
                xp: docs[i].xp,
                score: docs[i].score,
                quizCompleted: docs[i].quizCompleted,
              ),
          ];
        });
  }

  LeaderboardEntryDoc _leaderboardEntryFromUserSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    final xp = _repositoryIntValue(data['xp']);
    final name = _repositoryStringValue(data['name']).trim();
    final username = _repositoryStringValue(data['username']).trim();
    final email = _repositoryStringValue(data['email']).trim();

    return LeaderboardEntryDoc(
      uid: snapshot.id,
      rank: 0,
      name: name.isNotEmpty
          ? name
          : username.isNotEmpty
              ? username
              : email.isNotEmpty
                  ? email
                  : 'User',
      username: username,
      avatarUrl: _repositoryStringValue(data['avatarUrl']),
      level: _repositoryIntValue(data['level']),
      xp: xp,
      score: xp,
      quizCompleted: _repositoryIntValue(data['quizCompleted']),
    );
  }
}

int _repositoryIntValue(Object? value) => value is num ? value.toInt() : 0;
String _repositoryStringValue(Object? value) => value?.toString() ?? '';
