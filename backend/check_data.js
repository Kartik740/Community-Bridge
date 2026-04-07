require('dotenv').config();
const { db } = require('./src/config/firebase');

async function checkData() {
  try {
    const snap = await db.collection('responses').get();
    let count = 0;
    let approvedCount = 0;
    let locationCount = 0;
    let sample = null;

    snap.docs.forEach(d => {
       count++;
       const data = d.data();
       if (data.status === 'approved') approvedCount++;
       if (data.location) locationCount++;
       if (!sample) sample = data;
    });

    console.log(`Total Responses: ${count}`);
    console.log(`Approved: ${approvedCount}`);
    console.log(`With Location: ${locationCount}`);
    console.log(`Sample:`, JSON.stringify(sample, null, 2));

  } catch (e) {
    console.error(e);
  }
}

checkData();
