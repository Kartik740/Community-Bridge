const { messaging } = require('../config/firebase');

/**
 * Sends a push notification using Firebase Cloud Messaging
 * 
 * @param {string} token - FCM Device Token of the volunteer
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @returns {Promise<Object>} Response from FCM
 */
const sendNotification = async (token, title, body, data = {}) => {
  if (!token) {
    throw new Error('FCM token is missing');
  }

  const message = {
    notification: {
      title,
      body,
    },
    // data payload is what the Flutter app reads for routing on notification tap.
    // All values must be strings.
    data: Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v)])
    ),
    android: {
      notification: {
        channelId: 'community_bridge_tasks',
        priority: 'HIGH',
        sound: 'default',
      },
    },
    apns: {
      payload: {
        aps: { sound: 'default', badge: 1 },
      },
    },
    token,
  };

  try {
    const response = await messaging.send(message);
    console.log('Successfully sent message:', response);
    return response;
  } catch (error) {
    console.error('Error sending FCM message:', error);
    throw error;
  }
};

module.exports = { sendNotification };
