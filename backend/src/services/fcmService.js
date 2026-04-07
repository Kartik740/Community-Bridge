const { messaging } = require('../config/firebase');

/**
 * Sends a push notification using Firebase Cloud Messaging
 * 
 * @param {string} token - FCM Device Token of the volunteer
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @returns {Promise<Object>} Response from FCM
 */
const sendNotification = async (token, title, body) => {
  if (!token) {
    throw new Error('FCM token is missing');
  }

  const message = {
    notification: {
      title,
      body,
    },
    token: token
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
