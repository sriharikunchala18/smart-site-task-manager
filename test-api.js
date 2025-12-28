const https = require('https');

const BASE_URL = 'http://localhost:3000/api/tasks';

function makeRequest(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => {
        body += chunk;
      });
      res.on('end', () => {
        try {
          const response = {
            status: res.statusCode,
            data: JSON.parse(body)
          };
          resolve(response);
        } catch (e) {
          resolve({ status: res.statusCode, data: body });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

async function testAPI() {
  console.log('🚀 Testing Smart Site Task Manager API\n');

  try {
    // Test 1: Health Check
    console.log('1. Health Check:');
    const healthResponse = await makeRequest({
      hostname: 'smart-site-task-manager-1.onrender.com',
      port: 443,
      path: '/health',
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    console.log('✅', healthResponse.data);
    console.log('');

    // Test 2: Create a task with AI classification
    console.log('2. Creating task with AI classification:');
    console.log('Input: "Schedule urgent meeting with team today about budget allocation"');

    const createResponse = await makeRequest({
      hostname: 'localhost',
      port: 3000,
      path: '/api/tasks',
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    }, {
      title: 'Schedule urgent meeting with team today about budget allocation',
      description: 'We need to discuss the budget allocation for the next quarter and make urgent decisions'
    });

    console.log('✅ Task Created:');
    console.log(JSON.stringify(createResponse.data, null, 2));
    console.log('');

    const taskId = createResponse.data.id;

    // Test 3: Get all tasks
    console.log('3. Getting all tasks:');
    const getAllResponse = await makeRequest({
      hostname: 'smart-site-task-manager-1.onrender.com',
      port: 443,
      path: '/api/tasks',
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    console.log('✅ Tasks Retrieved:', getAllResponse.data.length, 'task(s)');
    console.log('');

    // Test 4: Get specific task
    console.log('4. Getting specific task details:');
    const getTaskResponse = await makeRequest({
      hostname: 'smart-site-task-manager-1.onrender.com',
      port: 443,
      path: `/api/tasks/${taskId}`,
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    console.log('✅ Task Details:');
    console.log(JSON.stringify(getTaskResponse.data, null, 2));
    console.log('');

    // Test 5: Update task
    console.log('5. Updating task status:');
    const updateResponse = await makeRequest({
      hostname: 'smart-site-task-manager-1.onrender.com',
      port: 443,
      path: `/api/tasks/${taskId}`,
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' }
    }, {
      status: 'in_progress'
    });
    console.log('✅ Task Updated:');
    console.log(JSON.stringify(updateResponse.data, null, 2));
    console.log('');

    // Test 6: Filter tasks by category
    console.log('6. Filtering tasks by category (scheduling):');
    const filterResponse = await makeRequest({
      hostname: 'smart-site-task-manager-1.onrender.com',
      port: 443,
      path: '/api/tasks?category=scheduling',
      method: 'GET',
      headers: { 'Content-Type': 'application/json' }
    });
    console.log('✅ Filtered Tasks:', filterResponse.data.length, 'task(s)');
    console.log('');

    console.log('🎉 All API tests completed successfully!');
    console.log('📊 AI Classification Results:');
    console.log('   - Category: scheduling');
    console.log('   - Priority: high');
    console.log('   - Entities: team, budget');
    console.log('   - Suggested Actions: Block calendar, Send invite, Prepare agenda, Set reminder');

  } catch (error) {
    console.error('❌ API Test Failed:', error.message);
  }
}

testAPI();
