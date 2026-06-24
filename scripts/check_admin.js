const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const keyPath = path.join(__dirname, 'serviceAccountKey.json');
const serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function checkAndFixAdmin() {
  console.log('═'.repeat(60));
  console.log('UOD — Admin Account Check & Fix');
  console.log('═'.repeat(60));

  // Get current user UID from environment or prompt
  const targetUid = process.argv[2];
  
  if (!targetUid) {
    console.log('\n❌ Error: Please provide your Firebase Auth UID');
    console.log('Usage: node check_admin.js <YOUR_UID>');
    console.log('\nTo get your UID:');
    console.log('1. Open Firebase Console > Authentication');
    console.log('2. Click on your user account');
    console.log('3. Copy the UID from the user details');
    process.exit(1);
  }

  console.log(`\nChecking UID: ${targetUid}...`);
  
  const userDocRef = db.collection('users').doc(targetUid);
  const userDoc = await userDocRef.get();

  if (userDoc.exists) {
    const data = userDoc.data();
    console.log('\n📋 Current User Data:');
    console.log(JSON.stringify(data, null, 2));
    
    if (data.role === 'admin' && data.status === 'approved') {
      console.log('\n✅ User already has admin role and is approved!');
    } else {
      console.log('\n⚠️ User does not have admin role or is not approved');
      console.log('\nFixing...');
      await userDocRef.update({
        role: 'admin',
        status: 'approved',
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
      });
      console.log('✅ Updated user to admin role!');
    }
  } else {
    console.log('\n⚠️ User document not found in Firestore');
    console.log('Creating admin user document...');
    await userDocRef.set({
      uid: targetUid,
      role: 'admin',
      status: 'approved',
      email: 'admin@uod.edu.ly',
      fullName: 'System Administrator',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
    console.log('✅ Created admin user document!');
  }

  console.log('\n' + '═'.repeat(60));
  console.log('DONE! Please try accessing system_logs again.');
  console.log('═'.repeat(60));
  
  process.exit(0);
}

checkAndFixAdmin().catch(err => {
  console.error('❌ Error:', err);
  process.exit(1);
});
