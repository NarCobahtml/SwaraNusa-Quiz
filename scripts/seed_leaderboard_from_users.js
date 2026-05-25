const fs = require('fs');
const os = require('os');
const path = require('path');

os.networkInterfaces = () => ({});

const admin = require('firebase-admin');

const localServiceAccountPath = path.resolve(__dirname, '../serviceAccountKey.json');
const defaultProjectId = 'swaranusa-quiz';

function loadServiceAccount() {
  if (!fs.existsSync(localServiceAccountPath)) return null;
  return require(localServiceAccountPath);
}

function loadCredential() {
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return admin.credential.applicationDefault();
  }

  const serviceAccount = loadServiceAccount();
  if (serviceAccount) {
    return admin.credential.cert(serviceAccount);
  }

  return admin.credential.applicationDefault();
}

function loadProjectId() {
  return process.env.FIREBASE_PROJECT_ID || defaultProjectId;
}

function numberValue(value, fallback = 0) {
  const number = Number(value);
  return Number.isFinite(number) ? number : fallback;
}

function stringValue(value, fallback = '') {
  return value === undefined || value === null ? fallback : String(value);
}

async function commitBatch(batch, pendingWrites) {
  if (pendingWrites === 0) return;
  await batch.commit();
}

async function seedLeaderboard() {
  admin.initializeApp({
    credential: loadCredential(),
    projectId: loadProjectId(),
  });

  const serviceAccount = loadServiceAccount();
  const targetProjectId = loadProjectId();

  if (serviceAccount?.project_id && serviceAccount.project_id !== targetProjectId) {
    console.warn(
      `Warning: serviceAccountKey.json project_id adalah "${serviceAccount.project_id}", ` +
        `tetapi target import adalah "${targetProjectId}". ` +
        'Jika muncul PERMISSION_DENIED, download service account key dari project target.',
    );
  }

  const db = admin.firestore();
  const usersSnapshot = await db.collection('users').get();

  if (usersSnapshot.empty) {
    console.log('Tidak ada dokumen di koleksi users. Leaderboard tidak dibuat.');
    return;
  }

  const users = usersSnapshot.docs
    .filter((doc) => !doc.id.startsWith('_'))
    .map((doc) => {
      const data = doc.data() || {};
      const xp = numberValue(data.xp);
      return {
        uid: doc.id,
        name:
          stringValue(data.name).trim() ||
          stringValue(data.username).trim() ||
          stringValue(data.email).trim() ||
          'User',
        username: stringValue(data.username),
        avatarUrl: stringValue(data.avatarUrl),
        level: numberValue(data.level, 1),
        xp,
        score: numberValue(data.score, xp),
        quizCompleted: numberValue(data.quizCompleted),
      };
    })
    .sort((a, b) => b.score - a.score);

  let batch = db.batch();
  let pendingWrites = 0;
  let totalWrites = 0;

  for (let i = 0; i < users.length; i += 1) {
    const user = users[i];
    const ref = db.collection('leaderboards/global/entries').doc(user.uid);

    batch.set(
      ref,
      {
        periodType: 'global',
        periodKey: 'global',
        rank: i + 1,
        name: user.name,
        username: user.username,
        avatarUrl: user.avatarUrl,
        level: user.level,
        xp: user.xp,
        score: user.score,
        quizCompleted: user.quizCompleted,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    pendingWrites += 1;
    totalWrites += 1;

    if (pendingWrites >= 450) {
      await commitBatch(batch, pendingWrites);
      batch = db.batch();
      pendingWrites = 0;
    }
  }

  await commitBatch(batch, pendingWrites);
  console.log(`Seeded ${totalWrites} leaderboard entries from users.`);
}

seedLeaderboard().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
