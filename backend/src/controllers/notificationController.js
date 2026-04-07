const { db } = require('../config/firebase');
const { sendNotification } = require('../services/fcmService');

/**
 * Endpoint to send FCM push notification to a volunteer about a task
 */
exports.notifyVolunteer = async (req, res) => {
  const { taskId, volunteerId } = req.params;

  try {
    const taskDoc = await db.collection('tasks').doc(taskId).get();
    const volunteerDoc = await db.collection('volunteers').doc(volunteerId).get();

    if (!taskDoc.exists || !volunteerDoc.exists) {
      return res.status(404).json({ error: 'Task or Volunteer not found' });
    }

    const task = taskDoc.data();
    const volunteer = volunteerDoc.data();

    if (!volunteer.fcmToken) {
      return res.status(400).json({ error: 'Volunteer has no FCM token' });
    }

    const title = `Urgent Request: ${task.title || task.category.toUpperCase()}`;
    const body = `You have been matched for a critical task in ${task.areaName}. Tap to view details.`;

    await sendNotification(volunteer.fcmToken, title, body);

    // Save Alert to DB
    const alertRef = db.collection('alerts').doc();
    await alertRef.set({
      taskId,
      volunteerId,
      message: body,
      sentAt: new Date(),
      readAt: null
    });

    res.status(200).json({ message: 'Notification sent successfully', alertId: alertRef.id });
  } catch (error) {
    console.error('Error in notifyVolunteer:', error);
    res.status(500).json({ error: error.message });
  }
};
