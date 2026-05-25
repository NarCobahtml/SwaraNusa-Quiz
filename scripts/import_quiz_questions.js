const fs = require('fs');
const os = require('os');
const path = require('path');

os.networkInterfaces = () => ({});

const admin = require('firebase-admin');

const defaultDataPath = path.resolve(__dirname, '../data/quiz_questions.json');
const dataPath = path.resolve(process.argv[2] || defaultDataPath);
const localServiceAccountPath = path.resolve(__dirname, '../serviceAccountKey.json');
const defaultProjectId = 'swaranusa-quiz';
const modeDefaults = {
  tebak_gambar: {
    title: 'Tebak Gambar',
    description: 'Tebak nama alat musik dari gambar.',
    iconUrl: 'assets/image/tebak_gambar.png',
    order: 1,
  },
  tebak_suara: {
    title: 'Tebak Suara',
    description: 'Tebak nama alat musik dari suara.',
    iconUrl: 'assets/image/tebak_suara.png',
    order: 2,
  },
  sejarah: {
    title: 'Sejarah',
    description: 'Jawab pertanyaan sejarah alat musik tradisional.',
    iconUrl: 'assets/image/sejarah_alat.png',
    order: 3,
  },
};

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
  return (
    process.env.FIREBASE_PROJECT_ID ||
    defaultProjectId
  );
}

function toNumber(value, fallback) {
  const numberValue = Number(value);
  return Number.isFinite(numberValue) ? numberValue : fallback;
}

function normalizeQuestion(raw, index) {
  const modeId = String(raw.modeId || 'tebak_gambar');
  const levelId = String(raw.levelId || `${modeId}_1`);
  const questionNumber = toNumber(raw.questionNumber, index + 1);
  const id = String(raw.id || `${levelId}_q${questionNumber}`);

  if (!Array.isArray(raw.options) || raw.options.length < 2) {
    throw new Error(`${id}: options harus berupa array minimal 2 pilihan.`);
  }

  if (!raw.correctAnswer) {
    throw new Error(`${id}: correctAnswer wajib diisi.`);
  }

  return {
    id,
    data: {
      modeId,
      levelId,
      questionNumber,
      title: String(raw.title || 'Tebak Gambar'),
      questionText: String(raw.questionText || ''),
      mediaType: String(raw.mediaType || 'image'),
      mediaUrl: String(raw.mediaUrl || ''),
      options: raw.options.map(String),
      correctAnswer: String(raw.correctAnswer),
      explanation: String(raw.explanation || ''),
      timeLimitSeconds: toNumber(raw.timeLimitSeconds, 30),
      points: toNumber(raw.points, 10),
      isActive: raw.isActive !== false,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    },
  };
}

function levelNumberFromId(levelId) {
  const match = String(levelId).match(/_(\d+)$/);
  return match ? Number(match[1]) : 1;
}

function levelTitle(modeId, levelNumber) {
  const modeTitle = modeDefaults[modeId]?.title || modeId;
  return `${modeTitle} Level ${levelNumber}`;
}

async function importQuestions() {
  if (!fs.existsSync(dataPath)) {
    throw new Error(`File data tidak ditemukan: ${dataPath}`);
  }

  admin.initializeApp({
    credential: loadCredential(),
    projectId: loadProjectId(),
  });

  const db = admin.firestore();
  const serviceAccount = loadServiceAccount();
  const targetProjectId = loadProjectId();

  if (serviceAccount?.project_id && serviceAccount.project_id !== targetProjectId) {
    console.warn(
      `Warning: serviceAccountKey.json project_id adalah "${serviceAccount.project_id}", ` +
        `tetapi target import adalah "${targetProjectId}". ` +
        'Jika muncul PERMISSION_DENIED, download service account key dari project target.',
    );
  }

  const rawQuestions = JSON.parse(fs.readFileSync(dataPath, 'utf8'));

  if (!Array.isArray(rawQuestions)) {
    throw new Error('Format JSON harus array berisi daftar soal.');
  }

  const questions = rawQuestions.map(normalizeQuestion);
  const modeIds = new Set();
  const levelCounts = new Map();
  let batch = db.batch();
  let pendingWrites = 0;
  let committedWrites = 0;

  async function addWrite(ref, data) {
    batch.set(ref, data, { merge: true });
    pendingWrites += 1;
    await commitIfNeeded();
  }

  async function commitIfNeeded(force = false) {
    if (pendingWrites === 0 || (!force && pendingWrites < 450)) return;
    await batch.commit();
    committedWrites += pendingWrites;
    batch = db.batch();
    pendingWrites = 0;
  }

  for (const question of questions) {
    modeIds.add(question.data.modeId);

    const count = levelCounts.get(question.data.levelId) || 0;
    levelCounts.set(question.data.levelId, count + 1);
  }

  for (const modeId of modeIds) {
    const mode = modeDefaults[modeId] || {
      title: modeId,
      description: '',
      iconUrl: '',
      order: 99,
    };

    await addWrite(db.collection('quiz_modes').doc(modeId), {
      ...mode,
      isActive: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  for (const [levelId, totalQuestions] of levelCounts) {
    const sampleQuestion = questions.find((question) => question.data.levelId === levelId);
    const modeId = sampleQuestion.data.modeId;
    const levelNumber = levelNumberFromId(levelId);

    await addWrite(db.collection('levels').doc(levelId), {
      modeId,
      levelNumber,
      title: levelTitle(modeId, levelNumber),
      description: '',
      totalQuestions,
      requiredXp: 0,
      unlockAfterLevelId: '',
      rewardXp: 50,
      rewardCoin: 100,
      isActive: true,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  }

  for (const question of questions) {
    await addWrite(db.collection('questions').doc(question.id), question.data);
  }

  await commitIfNeeded(true);

  console.log(
    `Imported ${questions.length} questions from ${dataPath}. Firestore writes: ${committedWrites}.`,
  );
}

importQuestions().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
