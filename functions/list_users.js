const admin = require('firebase-admin');

// Initialize Firebase Admin with project ID
admin.initializeApp({
  projectId: 'smart-college-app-442cd'
});

const db = admin.firestore();

async function run() {
  try {
    const snap = await db.collection('users').get();
    console.log(`Found ${snap.size} users:`);
    snap.forEach(doc => {
      const data = doc.data();
      console.log(`UID: ${doc.id} | Email: ${data.email} | Role: ${data.role} | Status: ${data.status}`);
    });
  } catch (err) {
    console.error('Error fetching users:', err);
  }
}

run();
