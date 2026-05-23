const os = require('os');

// Some WSL + mounted Windows drive environments throw on network interface
// detection inside Google auth libraries. The seed script does not need that
// detection, so keep it inert for this process.
os.networkInterfaces = () => ({});

const admin = require('firebase-admin');

const projectId = process.env.FIREBASE_PROJECT_ID || process.argv[2] || 'swaranusaquiz';
const credentialPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || '';

if (!credentialPath) {
  console.warn(
    'GOOGLE_APPLICATION_CREDENTIALS is not set. ' +
      'The script will use Application Default Credentials if available.',
  );
}

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId,
});

const db = admin.firestore();

const emptyTimestamp = null;

const writes = [
  {
    path: 'users/_template',
    data: {
      name: '',
      username: '',
      email: '',
      avatarUrl: '',
      level: 0,
      xp: 0,
      coin: 0,
      quizCompleted: 0,
      correctAnswerCount: 0,
      wrongAnswerCount: 0,
      badgesEarned: 0,
      isDarkMode: false,
      createdAt: emptyTimestamp,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'users/_template/level_progress/_template',
    data: {
      modeId: '',
      status: '',
      isUnlocked: false,
      stars: 0,
      bestScore: 0,
      bestCorrectAnswers: 0,
      attemptCount: 0,
      completedAt: emptyTimestamp,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'users/_template/quiz_attempts/_template',
    data: {
      modeId: '',
      levelId: '',
      totalQuestions: 0,
      correctAnswers: 0,
      wrongAnswers: 0,
      score: 0,
      earnedXp: 0,
      earnedCoin: 0,
      durationSeconds: 0,
      startedAt: emptyTimestamp,
      finishedAt: emptyTimestamp,
      createdAt: emptyTimestamp,
    },
  },
  {
    path: 'users/_template/quiz_attempts/_template/answers/_template',
    data: {
      questionId: '',
      questionNumber: 0,
      userAnswer: '',
      correctAnswer: '',
      isCorrect: false,
      timeSpentSeconds: 0,
      pointsEarned: 0,
      createdAt: emptyTimestamp,
    },
  },
  {
    path: 'users/_template/mission_progress/_template',
    data: {
      progress: 0,
      target: 0,
      isCompleted: false,
      isClaimed: false,
      dateKey: '',
      completedAt: emptyTimestamp,
      claimedAt: emptyTimestamp,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'users/_template/owned_instruments/_template',
    data: {
      isUnlocked: false,
      unlockedAt: emptyTimestamp,
      source: '',
    },
  },
  {
    path: 'users/_template/achievements/_template',
    data: {
      earnedAt: emptyTimestamp,
    },
  },
  {
    path: 'users/_template/daily_login/current',
    data: {
      currentStreak: 0,
      lastLoginDate: '',
      claimedToday: false,
      totalLoginDays: 0,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'quiz_modes/_template',
    data: {
      title: '',
      description: '',
      iconUrl: '',
      order: 0,
      isActive: false,
      createdAt: emptyTimestamp,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'levels/_template',
    data: {
      modeId: '',
      levelNumber: 0,
      title: '',
      description: '',
      totalQuestions: 0,
      requiredXp: 0,
      unlockAfterLevelId: '',
      rewardXp: 0,
      rewardCoin: 0,
      isActive: false,
      createdAt: emptyTimestamp,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'questions/_template',
    data: {
      modeId: '',
      levelId: '',
      questionNumber: 0,
      title: '',
      questionText: '',
      mediaType: '',
      mediaUrl: '',
      options: ['', '', '', ''],
      correctAnswer: '',
      explanation: '',
      timeLimitSeconds: 0,
      points: 0,
      isActive: false,
      createdAt: emptyTimestamp,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'instruments/_template',
    data: {
      name: '',
      region: '',
      description: '',
      imageUrl: '',
      audioUrl: '',
      price: 0,
      isUnlockable: false,
      opensMinigame: false,
      isActive: false,
      createdAt: emptyTimestamp,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'missions/_template',
    data: {
      title: '',
      description: '',
      type: '',
      targetType: '',
      targetValue: 0,
      rewardXp: 0,
      rewardCoin: 0,
      rewardInstrumentId: '',
      iconUrl: '',
      isActive: false,
      createdAt: emptyTimestamp,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'achievements/_template',
    data: {
      name: '',
      description: '',
      iconUrl: '',
      stars: 0,
      conditionType: '',
      conditionValue: 0,
      isActive: false,
      createdAt: emptyTimestamp,
      updatedAt: emptyTimestamp,
    },
  },
  {
    path: 'daily_login_rewards/_template',
    data: {
      dayNumber: 0,
      rewardXp: 0,
      rewardCoin: 0,
      rewardInstrumentId: '',
      isActive: false,
    },
  },
  {
    path: 'leaderboards/global/entries/_template',
    data: {
      periodType: 'global',
      periodKey: 'global',
      rank: 0,
      name: '',
      username: '',
      avatarUrl: '',
      level: 0,
      xp: 0,
      score: 0,
      quizCompleted: 0,
      updatedAt: emptyTimestamp,
    },
  },
];

async function seed() {
  const batch = db.batch();

  for (const write of writes) {
    batch.set(db.doc(write.path), write.data, { merge: true });
  }

  await batch.commit();
  console.log(`Seeded ${writes.length} Firestore template documents to project ${projectId}.`);
}

seed().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
