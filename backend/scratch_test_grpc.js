require('dotenv').config();
const { db } = require('./src/config/firebase');

async function testGrpc() {
   try {
      console.log('Fetching tasks to test gRPC auth...');
      const taskDoc = await db.collection('tasks').limit(1).get();
      console.log('Success, docs found:', taskDoc.size);
   } catch (err) {
      console.error('Error during gRPC call:', err.message);
   }
}

testGrpc();
