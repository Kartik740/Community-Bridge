const { db } = require('../config/firebase');
const { formatResponses } = require('../utils/responseFormatter');
const { analyseResponses } = require('../services/geminiService');
const { matchVolunteers } = require('../services/matchingService');

/**
 * Fetches approved responses for an org, sends them to Gemini for clustering/tasks.
 */
exports.runAnalysis = async (req, res) => {
  const { orgId } = req.params;

  try {
    // 1. Fetch approved responses
    const responsesSnapshot = await db.collection('responses')
      .where('orgId', '==', orgId)
      .where('status', '==', 'approved')
      .get();
      
    if (responsesSnapshot.empty) {
      return res.status(200).json({ message: 'No approved responses found to analyse.', tasks: [] });
    }

    const responses = formatResponses(responsesSnapshot.docs);

    // 2. Call Gemini
    const tasksData = await analyseResponses(responses);

    // 3. Process generated tasks & save to Firestore
    const createdTasks = [];
    const batch = db.batch();

    // 4. Fetch volunteers for immediate matching if urgency > 7
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
        // Mocking location based on response clusters (simplified for demo)
        location: responses.length > 0 && responses[0].location ? responses[0].location : { lat: 23.2599, lng: 77.4126 } // Default Bhopal
      };

      // 4b. Match Engine if Urgent
      if (taskObj.urgencyScore >= 7 && volunteers.length > 0) {
          taskObj.suggestedVolunteers = matchVolunteers(taskObj, volunteers);
      }

      batch.set(taskRef, taskObj);
      createdTasks.push({ id: taskRef.id, ...taskObj });
    }

    await batch.commit();

    // Optionally mark these responses as 'analysed' to prevent duplicate runs
    const responseBatch = db.batch();
    responsesSnapshot.docs.forEach(doc => {
       responseBatch.update(doc.ref, { status: 'analysed' });
    });
    await responseBatch.commit();

    res.status(200).json({ message: 'Analysis complete', tasks: createdTasks });
  } catch (error) {
    console.error('Error running analysis:', error);
    res.status(500).json({ error: error.message });
  }
};
