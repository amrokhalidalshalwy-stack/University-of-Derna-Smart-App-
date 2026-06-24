const PROJECT_ID = 'smart-college-app-442cd';
const FIRESTORE_HOST = '127.0.0.1:8081';
const AUTH_HOST = '127.0.0.1:9099';

// Use native fetch (available in Node.js 18+)
async function fetch(url, options) {
  const response = await global.fetch(url, options);
  return response;
}

async function testGPAProtection() {
  const uid = 'JGAeGek2qL4l5agBeYgrmgHDWROz';
  
  try {
    // Step 1: Create user document with role: student (using admin privileges - no auth needed for emulator)
    console.log('Step 1: Creating user document...');
    const createUrl = `http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${uid}`;
    const createBody = {
      fields: {
        role: { stringValue: 'student' },
        displayName: { stringValue: 'Test Student' },
        photoUrl: { stringValue: 'http://example.com/photo.jpg' },
        gpa: { doubleValue: 3.5 }
      }
    };
    
    const createResponse = await fetch(createUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(createBody)
    });
    
    if (!createResponse.ok) {
      const error = await createResponse.text();
      console.log('Create response:', error);
    } else {
      console.log('✓ User document created successfully');
    }
    
    // Step 2: Get auth token for student
    console.log('\nStep 2: Getting auth token for student...');
    const authUrl = `http://${AUTH_HOST}/identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=fake-api-key`;
    const authBody = {
      email: 'student@test.com',
      password: 'test123456',
      returnSecureToken: true
    };
    
    const authResponse = await fetch(authUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(authBody)
    });
    
    const authData = await authResponse.json();
    const idToken = authData.idToken;
    console.log('✓ Auth token obtained');
    
    // Step 3: Try to update GPA field only (as student)
    console.log('\nStep 3: Attempting to update GPA field as student...');
    const updateUrl = `http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/users/${uid}?updateMask.fieldPaths=gpa`;
    const updateBody = {
      fields: {
        gpa: { doubleValue: 4.0 }
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
    
    const updateResult = await updateResponse.json();
    console.log('Status Code:', updateResponse.status);
    console.log('Response:', JSON.stringify(updateResult, null, 2));
    
    if (updateResponse.ok) {
      console.log('✗ UNEXPECTED: GPA update succeeded (this should have been blocked!)');
      return { success: true, message: 'GPA update succeeded (security issue!)', status: updateResponse.status, response: updateResult };
    } else {
      console.log('✓ EXPECTED: GPA update was blocked');
      return { success: false, message: 'GPA update blocked as expected', status: updateResponse.status, response: updateResult };
    }
    
  } catch (error) {
    console.error('Error:', error);
    return { success: false, message: 'Test failed', error: error.message };
  }
}

testGPAProtection().then(result => {
  console.log('\n=== Test Result ===');
  console.log(JSON.stringify(result, null, 2));
  process.exit(0);
}).catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
