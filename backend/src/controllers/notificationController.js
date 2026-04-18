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

    // ── BUG FIX 1: write assignedVolunteerId + status to the task document ──
    // The mobile TaskProvider queries tasks by 'assignedVolunteerId'.
    // Without this update the task never appears in the volunteer's Tasks tab.
    await db.collection('tasks').doc(taskId).update({
      assignedVolunteerId: volunteerId,
      status: 'assigned',
      assignedAt: new Date(),
    });

    // ── BUG FIX 2: pass taskId in FCM data payload ──
    // The Flutter app reads message.data['taskId'] to navigate on notification tap.
    await sendNotification(volunteer.fcmToken, title, body, {
      taskId,
      volunteerId,
      type: 'task_assigned',
    });

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
