/**
 * Firebase Admin SDK initialization.
 * Reads credentials from environment variables securely.
 */
const admin = require('firebase-admin');

if (!admin.apps.length) {
  try {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        // Replace escaped newlines with actual newlines
        privateKey: process.env.FIREBASE_PRIVATE_KEY ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n') : '',
      }),
    });
    console.log('Firebase Admin initialized successfully.');
  } catch (err) {
    console.error('Firebase Admin initialization error:', err.message);
  }
}

const db = admin.firestore();
const messaging = admin.messaging();

module.exports = { admin, db, messaging };
