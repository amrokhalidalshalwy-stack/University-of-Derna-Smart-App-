const PROJECT_ID = 'smart-college-app-442cd';
const FIRESTORE_HOST = '127.0.0.1:8082';
const AUTH_HOST = '127.0.0.1:9100';

// Use native fetch (available in Node.js 18+)
async function fetch(url, options) {
  const response = await global.fetch(url, options);
  return response;
}

async function main() {
  console.log('=== Testing courses collection rules ===\n');

  // Step 1: Create a faculty user
  console.log('Step 1: Creating faculty user...');
  const facultyEmail = 'faculty@test.com';
  const facultyPassword = 'test123456';
  
  try {
    const authResponse = await fetch(`http://${AUTH_HOST}/v1/projects/${PROJECT_ID}/accounts:signUp?key=AIzaSyDummyKey`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: facultyEmail,
        password: facultyPassword,
        returnSecureToken: true
      })
    });
    const authResult = await authResponse.json();
    console.log('Faculty user created:', authResult.localId);
    const facultyUid = authResult.localId;
    const idToken = authResult.idToken;

    // Step 2: Create faculty user document
    console.log('\nStep 2: Creating faculty user document...');
    const userResponse = await fetch(`http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${facultyUid}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      body: JSON.stringify({
        fields: {
          uid: { stringValue: facultyUid },
          email: { stringValue: facultyEmail },
          role: { stringValue: 'faculty' },
          fullName: { stringValue: 'Test Faculty' }
        }
      })
    });
    console.log('User document status:', userResponse.status);

    // Step 3: Create a course WITHOUT this faculty in assigned_professors
    console.log('\nStep 3: Creating course WITHOUT faculty in assigned_professors...');
    const courseId = 'test_course_123';
    const courseResponse = await fetch(`http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/courses/${courseId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      body: JSON.stringify({
        fields: {
          name: { stringValue: 'Test Course' },
          code: { stringValue: 'CS101' },
          assigned_professors: { arrayValue: { values: [] } }
        }
      })
    });
    console.log('Course creation status:', courseResponse.status);
    if (courseResponse.status !== 200) {
      console.log('Note: Course creation may fail due to missing admin rules, but we can still test update');
    }

    // Step 4: Attempt to update gradingStats as NON-assigned faculty
    console.log('\nStep 4: Attempting to update gradingStats as NON-assigned faculty...');
    const updateUrl = `http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/courses/${courseId}?updateMask.fieldPaths=gradingStats`;
    const updateBody = {
      fields: {
        gradingStats: {
          mapValue: {
            fields: {
              totalStudents: { integerValue: 50 },
              gradedCoursework: { integerValue: 30 }
            }
          }
        }
      }
    };

    const updateResponse = await fetch(updateUrl, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      body: JSON.stringify(updateBody)
    });

    console.log('Status Code:', updateResponse.status);
    const updateResult = await updateResponse.json();
    console.log('Response:', JSON.stringify(updateResult, null, 2));

    // Step 5: Add faculty to assigned_professors
    console.log('\nStep 5: Adding faculty to assigned_professors...');
    const assignResponse = await fetch(`http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/courses/${courseId}?updateMask.fieldPaths=assigned_professors`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      body: JSON.stringify({
        fields: {
          assigned_professors: {
            arrayValue: {
              values: [
                { stringValue: facultyUid }
              ]
            }
          }
        }
      })
    });
    console.log('Assign faculty status:', assignResponse.status);

    // Step 6: Attempt to update gradingStats as ASSIGNED faculty
    console.log('\nStep 6: Attempting to update gradingStats as ASSIGNED faculty...');
    const updateResponse2 = await fetch(updateUrl, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${idToken}`
      },
      body: JSON.stringify(updateBody)
    });

    console.log('Status Code:', updateResponse2.status);
    const updateResult2 = await updateResponse2.json();
    console.log('Response:', JSON.stringify(updateResult2, null, 2));

  } catch (error) {
    console.error('Error:', error);
  }
}

main();
