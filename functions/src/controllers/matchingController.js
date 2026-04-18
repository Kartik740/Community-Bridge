const { db } = require('../config/firebase');
const { matchVolunteers } = require('../services/matchingService');

/**
 * Controller to manually trigger matching for a task
 */
exports.matchTask = async (req, res) => {
  const { taskId } = req.params;

  try {
    const taskDoc = await db.collection('tasks').doc(taskId).get();
    if (!taskDoc.exists) {
      return res.status(404).json({ error: 'Task not found' });
    }
    const task = { id: taskDoc.id, ...taskDoc.data() };

    const volsSnapshot = await db.collection('volunteers').where('orgId', '==', task.orgId).get();
    if (volsSnapshot.empty) {
         return res.status(200).json({ suggestedVolunteers: [] });
    }

    const volunteers = volsSnapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
    
    const suggestedVolunteers = matchVolunteers(task, volunteers);

    // Save to Firestore
    await db.collection('tasks').doc(taskId).update({
      suggestedVolunteers
    });

    res.status(200).json({ suggestedVolunteers, message: 'Matching complete' });
  } catch (error) {
    console.error('Error in task matching:', error);
    res.status(500).json({ error: error.message });
  }
};
