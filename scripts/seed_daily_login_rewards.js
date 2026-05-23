// Script untuk seed koleksi daily_login_rewards ke Firestore
// Jalankan: node scripts/seed_daily_login_rewards.js

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const rewards = [
  { day: 1, rewardCoin: 100, rewardXp: 50 },
  { day: 2, rewardCoin: 100, rewardXp: 50 },
  { day: 3, rewardCoin: 150, rewardXp: 75 },
  { day: 4, rewardCoin: 100, rewardXp: 50 },
  { day: 5, rewardCoin: 150, rewardXp: 75 },
  { day: 6, rewardCoin: 200, rewardXp: 100 },
  { day: 7, rewardCoin: 300, rewardXp: 150 }, // bonus hari ke-7
];

async function seed() {
  const batch = db.batch();
  for (const reward of rewards) {
    const ref = db.collection('daily_login_rewards').doc(`day_${reward.day}`);
    batch.set(ref, {
      day: reward.day,
      rewardCoin: reward.rewardCoin,
      rewardXp: reward.rewardXp,
      rewardInstrumentId: '',
    });
  }
  await batch.commit();
  console.log('✅ daily_login_rewards seeded successfully');
  process.exit(0);
}

seed().catch((err) => {
  console.error('❌ Error:', err);
  process.exit(1);
});
