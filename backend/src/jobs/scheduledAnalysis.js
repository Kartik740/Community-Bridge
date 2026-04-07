const cron = require('node-cron');
const { db } = require('../config/firebase');
const { formatResponses } = require('../utils/responseFormatter');
const { analyseResponses } = require('../services/geminiService');
const { matchVolunteers } = require('../services/matchingService');

// Schedule tasks to be run on the server. Every day at midnight.
cron.schedule('0 0 * * *', async () => {
  console.log('Running scheduled daily analysis...');

  try {
    const orgsSnapshot = await db.collection('organisations').get();
    
    for (const org of orgsSnapshot.docs) {
      const orgId = org.id;
      
      const responsesSnapshot = await db.collection('responses')
        .where('orgId', '==', orgId)
        .where('status', '==', 'approved')
        .get();

      if (!responsesSnapshot.empty) {
        const responses = formatResponses(responsesSnapshot.docs);
        const tasksData = await analyseResponses(responses);

        const batch = db.batch();
        let volunteers = [];
        const volsSnapshot = await db.collection('volunteers').where('orgId', '==', orgId).get();
        if (!volsSnapshot.empty) {
            volunteers = volsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        }

        for (const taskData of tasksData) {
          const taskRef = db.collection('tasks').doc();
          const taskObj = {
            orgId,
            ...taskData,
            status: 'open',
            assignedVolunteerId: null,
            suggestedVolunteers: [],
            createdAt: new Date(),
            location: responses.length > 0 && responses[0].location ? responses[0].location : { lat: 23.2599, lng: 77.4126 }
          };

          if (taskObj.urgencyScore >= 7 && volunteers.length > 0) {
            taskObj.suggestedVolunteers = matchVolunteers(taskObj, volunteers);
          }

          batch.set(taskRef, taskObj);
        }

        responsesSnapshot.docs.forEach(doc => {
           batch.update(doc.ref, { status: 'analysed' });
        });
        
        await batch.commit();
        console.log(`Completed analysis for org: ${orgId}`);
      }
    }
  } catch (error) {
    console.error('Error in scheduled daily analysis:', error);
  }
});

console.log('Daily cron job registered.');
