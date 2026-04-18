const { db } = require('../config/firebase');

exports.deleteSurvey = async (req, res) => {
  const { surveyId, orgId } = req.body;
  if (!surveyId || !orgId) {
     return res.status(400).json({ error: 'Missing surveyId or orgId' });
  }

  try {
     const batch = db.batch();
     
     // 1. Find the survey by ID or surveyCode
     let surveyDoc = await db.collection('surveys').doc(surveyId).get();
     if (!surveyDoc.exists) {
        // Fallback: search by surveyCode
        const snap = await db.collection('surveys').where('surveyCode', '==', surveyId).where('orgId', '==', orgId).limit(1).get();
        if (snap.empty) {
           return res.status(404).json({ error: 'Survey not found' });
        }
        surveyDoc = snap.docs[0];
     }
     
     const actualSurveyCode = surveyDoc.data().surveyCode || surveyId;
     
     // Add survey to deletion batch
     batch.delete(surveyDoc.ref);
     
     // 2. Fetch responses associated with this survey
     const r1 = await db.collection('responses').where('surveyId', '==', surveyId).where('orgId', '==', orgId).get();
     const r2 = surveyDoc.id !== actualSurveyCode 
        ? await db.collection('responses').where('surveyId', '==', actualSurveyCode).where('orgId', '==', orgId).get() 
        : { empty: true, docs: [] };
        
     const allResponses = [...r1.docs, ...r2.docs];
     const responsesToDelete = [];
     
     const uniqueIds = new Set();
     allResponses.forEach(docSnap => {
         if (!uniqueIds.has(docSnap.id)) {
            uniqueIds.add(docSnap.id);
            responsesToDelete.push({ id: docSnap.id, ...docSnap.data() });
            batch.delete(docSnap.ref);
         }
     });
     
     // 3. Find associated tasks matching those response locations
     let tasksDeleted = 0;
     if (responsesToDelete.length > 0) {
         const tasksSnap = await db.collection('tasks').where('orgId', '==', orgId).get();
         tasksSnap.docs.forEach(taskDoc => {
             const tLoc = taskDoc.data().location;
             if (tLoc) {
                const match = responsesToDelete.some(r => r.location && r.location.lat === tLoc.lat && r.location.lng === tLoc.lng);
                if (match) {
                   batch.delete(taskDoc.ref);
                   tasksDeleted++;
                }
             }
         });
     }
     
     // 4. Commit batch
     await batch.commit();

     res.status(200).json({ 
        message: `Deleted survey ${surveyDoc.data().title}, ${responsesToDelete.length} responses, and ${tasksDeleted} tasks.`
     });
  } catch (err) {
     console.error('Error deleting survey:', err);
     res.status(500).json({ error: 'Failed to delete survey' });
  }
};
