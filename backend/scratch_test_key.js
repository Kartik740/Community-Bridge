require('dotenv').config();
const { admin, messaging } = require('./src/config/firebase');

async function test() {
   try {
      const response = await messaging.send({
         token: 'dummy-token',
         notification: { title: 'Test', body: 'Test' }
      });
      console.log('Success:', response);
   } catch (err) {
      console.error('Error:', err.message);
   }
}

test();
