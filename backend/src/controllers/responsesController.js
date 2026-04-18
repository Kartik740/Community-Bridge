const { db } = require('../config/firebase');

/**
 * Bulk delete responses and their related AI generated tasks.
 */
exports.deleteResponses = async (req, res) => {
  const { ids, orgId } = req.body;
  if (!ids || !orgId) {
     return res.status(400).json({ error: 'Missing response ids or orgId' });
  }

  try {
     const batch = db.batch();
     const responsesToDelete = [];
     
     // 1. Fetch responses to determine locations
     for (const id of ids) {
        const docSnap = await db.collection('responses').doc(id).get();
        if (docSnap.exists) {
           responsesToDelete.push({ id, ...docSnap.data() });
           batch.delete(docSnap.ref); // add response delete to batch
        }
     }
     
     const tasksSnap = await db.collection('tasks').where('orgId', '==', orgId).get();
     let tasksDeleted = 0;
     
     // 2. Add tasks matching locations to batch
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
     
     // 3. Commit the batch
     await batch.commit();

     res.status(200).json({ message: `Deleted ${responsesToDelete.length} responses and ${tasksDeleted} associated tasks.`, tasksDeleted });
  } catch (err) {
     console.error('Error deleting responses:', err);
     res.status(500).json({ error: 'Failed to delete responses or tasks from database.' });
  }
};
