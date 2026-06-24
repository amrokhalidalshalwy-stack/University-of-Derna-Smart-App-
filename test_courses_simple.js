const PROJECT_ID = 'smart-college-app-442cd';
const FIRESTORE_HOST = '127.0.0.1:8082';

// Use native fetch (available in Node.js 18+)
async function fetch(url, options) {
  const response = await global.fetch(url, options);
  return response;
}

async function main() {
  console.log('=== Testing courses collection rules ===\n');

  try {
    // Step 1: Create a course WITHOUT assigned_professors
    console.log('Step 1: Creating course WITHOUT assigned_professors...');
    const courseId = 'test_course_123';
    
    const courseResponse = await fetch(`http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/courses/${courseId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json'
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

    // Step 2: Attempt to update gradingStats WITHOUT authentication
    console.log('\nStep 2: Attempting to update gradingStats WITHOUT authentication...');
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
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(updateBody)
    });

    console.log('Status Code:', updateResponse.status);
    const updateResult = await updateResponse.json();
    console.log('Response:', JSON.stringify(updateResult, null, 2));

    // Step 3: Add a faculty UID to assigned_professors
    console.log('\nStep 3: Adding faculty to assigned_professors...');
    const facultyUid = 'test_faculty_uid_123';
    const assignResponse = await fetch(`http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/courses/${courseId}?updateMask.fieldPaths=assigned_professors`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json'
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

    // Step 4: Attempt to update gradingStats again (still WITHOUT authentication)
    console.log('\nStep 4: Attempting to update gradingStats again (still WITHOUT authentication)...');
    const updateResponse2 = await fetch(updateUrl, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(updateBody)
    });

    console.log('Status Code:', updateResponse2.status);
    const updateResult2 = await updateResponse2.json();
    console.log('Response:', JSON.stringify(updateResult2, null, 2));

    // Cleanup
    console.log('\nCleaning up...');
    await fetch(`http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/courses/${courseId}`, {
      method: 'DELETE'
    });
    console.log('Cleanup complete');

  } catch (error) {
    console.error('Error:', error);
  }
}

main();
