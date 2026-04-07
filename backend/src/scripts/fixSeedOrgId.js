const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
const { db } = require('../config/firebase');

async function fixData() {
  console.log('Fetching organizations...');
  const orgsSnap = await db.collection('organisations').get();
  
  // Find the real user org (not test-org-123)
  const realOrg = orgsSnap.docs.find(doc => doc.id !== 'test-org-123' && doc.id !== 'helping-hands');
  
  let targetOrgId;
  if (!realOrg) {
    // maybe there's only one org and it's the real one
    if (orgsSnap.docs.length > 0) {
        targetOrgId = orgsSnap.docs[0].id;
    } else {
        console.log('No organizations exist to map to.');
        return;
    }
  } else {
      targetOrgId = realOrg.id;
  }
  
  console.log(`Mapping all mock data to actual User Organization ID: ${targetOrgId}`);

  const collections = ['tasks', 'volunteers', 'responses', 'surveys'];
  
  for (const coll of collections) {
     const snap = await db.collection(coll).get();
     let batch = db.batch();
     let count = 0;
     snap.docs.forEach(doc => {
         batch.update(doc.ref, { orgId: targetOrgId });
         count++;
     });
     if (count > 0) {
        await batch.commit();
        console.log(`Mapped ${count} documents in '${coll}' collection to ${targetOrgId}`);
     } else {
        console.log(`No documents found in '${coll}'`);
     }
  }
  
  console.log('\n✅ Data mapping successfully completed!');
}

fixData().catch(console.error).finally(()=>process.exit(0));
