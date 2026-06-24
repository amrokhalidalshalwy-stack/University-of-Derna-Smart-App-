const admin = require('firebase-admin');
const PROJECT_ID = 'smart-college-app-442cd';

admin.initializeApp({
  projectId: PROJECT_ID,
  credential: admin.credential.applicationDefault()
});

const db = admin.firestore();
const auth = admin.auth();

// Use emulator
db.settings({
  host: '127.0.0.1:8082',
  ssl: false
});

auth.useEmulator('http://127.0.0.1:9100');

async function main() {
  console.log('=== Testing courses collection rules ===\n');

  try {
    // Step 1: Create a faculty user
    console.log('Step 1: Creating faculty user...');
    const facultyEmail = 'faculty@test.com';
    const facultyPassword = 'test123456';
    
    const userRecord = await auth.createUser({
      email: facultyEmail,
      password: facultyPassword,
    });
    console.log('Faculty user created:', userRecord.uid);
    const facultyUid = userRecord.uid;

    // Step 2: Create faculty user document
    console.log('\nStep 2: Creating faculty user document...');
    await db.collection('users').doc(facultyUid).set({
      uid: facultyUid,
      email: facultyEmail,
      role: 'faculty',
      fullName: 'Test Faculty'
    });
    console.log('User document created successfully');

    // Step 3: Create a course WITHOUT this faculty in assigned_professors
    console.log('\nStep 3: Creating course WITHOUT faculty in assigned_professors...');
    const courseId = 'test_course_123';
    await db.collection('courses').doc(courseId).set({
      name: 'Test Course',
      code: 'CS101',
      assigned_professors: []
    });
    console.log('Course created successfully');

    // Step 4: Attempt to update gradingStats as NON-assigned faculty
    console.log('\nStep 4: Attempting to update gradingStats as NON-assigned faculty...');
    try {
      await db.collection('courses').doc(courseId).update({
        gradingStats: {
          totalStudents: 50,
          gradedCoursework: 30
        }
      });
      console.log('Status Code: 200 (UNEXPECTED - should have been denied)');
    } catch (error) {
      console.log('Status Code: 403 (PERMISSION_DENIED)');
      console.log('Response:', error.message);
    }

    // Step 5: Add faculty to assigned_professors
    console.log('\nStep 5: Adding faculty to assigned_professors...');
    await db.collection('courses').doc(courseId).update({
      assigned_professors: [facultyUid]
    });
    console.log('Faculty added to assigned_professors successfully');

    // Step 6: Attempt to update gradingStats as ASSIGNED faculty
    console.log('\nStep 6: Attempting to update gradingStats as ASSIGNED faculty...');
    try {
      await db.collection('courses').doc(courseId).update({
        gradingStats: {
          totalStudents: 50,
          gradedCoursework: 30
        }
      });
      console.log('Status Code: 200 (SUCCESS)');
      console.log('Response: Update successful');
    } catch (error) {
      console.log('Status Code: 403 (PERMISSION_DENIED)');
      console.log('Response:', error.message);
    }

    // Cleanup
    console.log('\nCleaning up...');
    await auth.deleteUser(facultyUid);
    await db.collection('users').doc(facultyUid).delete();
    await db.collection('courses').doc(courseId).delete();
    console.log('Cleanup complete');

  } catch (error) {
    console.error('Error:', error);
  }
}

main();
