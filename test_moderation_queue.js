const PROJECT_ID = 'smart-college-app-442cd';
const FIRESTORE_HOST = '127.0.0.1:8082';

// Use native fetch (available in Node.js 18+)
async function fetch(url, options) {
  const response = await global.fetch(url, options);
  return response;
}

async function main() {
  console.log('=== Testing moderation_queue collection rules ===\n');

  try {
    // Step 1: Attempt to create moderation_queue document WITHOUT authentication
    console.log('Step 1: Attempting to create moderation_queue document WITHOUT authentication...');
    const createUrl = `http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/moderation_queue?documentId=test_queue_1`;
    const createBody = {
      fields: {
        type: { stringValue: 'post' },
        post_id: { stringValue: 'test_post_1' },
        reported_by: { stringValue: 'user_123' },
        reason: { stringValue: 'Spam' },
        report_count: { integerValue: 1 },
        auto_hidden: { booleanValue: false },
        status: { stringValue: 'pending' }
      }
    };

    const createResponse = await fetch(createUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(createBody)
    });

    console.log('Status Code:', createResponse.status);
    const createResult = await createResponse.json();
    console.log('Response:', JSON.stringify(createResult, null, 2));

    // Step 2: Attempt to create moderation_queue document with report_count = 999 (should be denied)
    console.log('\nStep 2: Attempting to create moderation_queue document with report_count = 999 (should be denied)...');
    const createBody2 = {
      fields: {
        type: { stringValue: 'post' },
        post_id: { stringValue: 'test_post_1' },
        reported_by: { stringValue: 'user_123' },
        reason: { stringValue: 'Spam' },
        report_count: { integerValue: 999 },
        auto_hidden: { booleanValue: false },
        status: { stringValue: 'pending' }
      }
    };

    const createResponse2 = await fetch(`http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/moderation_queue?documentId=test_queue_2`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(createBody2)
    });

    console.log('Status Code:', createResponse2.status);
    const createResult2 = await createResponse2.json();
    console.log('Response:', JSON.stringify(createResult2, null, 2));

    // Step 3: Attempt to create moderation_queue document with auto_hidden = true (should be denied)
    console.log('\nStep 3: Attempting to create moderation_queue document with auto_hidden = true (should be denied)...');
    const createBody3 = {
      fields: {
        type: { stringValue: 'post' },
        post_id: { stringValue: 'test_post_1' },
        reported_by: { stringValue: 'user_123' },
        reason: { stringValue: 'Spam' },
        report_count: { integerValue: 1 },
        auto_hidden: { booleanValue: true },
        status: { stringValue: 'pending' }
      }
    };

    const createResponse3 = await fetch(`http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/moderation_queue?documentId=test_queue_3`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(createBody3)
    });

    console.log('Status Code:', createResponse3.status);
    const createResult3 = await createResponse3.json();
    console.log('Response:', JSON.stringify(createResult3, null, 2));

    // Step 4: Attempt to create moderation_queue document with status = 'approved' (should be denied)
    console.log('\nStep 4: Attempting to create moderation_queue document with status = "approved" (should be denied)...');
    const createBody4 = {
      fields: {
        type: { stringValue: 'post' },
        post_id: { stringValue: 'test_post_1' },
        reported_by: { stringValue: 'user_123' },
        reason: { stringValue: 'Spam' },
        report_count: { integerValue: 1 },
        auto_hidden: { booleanValue: false },
        status: { stringValue: 'approved' }
      }
    };

    const createResponse4 = await fetch(`http://${FIRESTORE_HOST}/v1/projects/${PROJECT_ID}/databases/(default)/documents/moderation_queue?documentId=test_queue_4`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(createBody4)
    });

    console.log('Status Code:', createResponse4.status);
    const createResult4 = await createResponse4.json();
    console.log('Response:', JSON.stringify(createResult4, null, 2));

  } catch (error) {
    console.error('Error:', error);
  }
}

main();
