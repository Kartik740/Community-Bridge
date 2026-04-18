/**
 * Firebase Admin SDK initialization.
 * Reads credentials from environment variables securely.
 */
const admin = require('firebase-admin');

if (!admin.apps.length) {
  try {
    let privateKey = process.env.FIREBASE_PRIVATE_KEY || '';
    // Strip wrapping literal quotes if they exist (common deployment platform issue like in Render)
    if (privateKey.startsWith('"') && privateKey.endsWith('"')) {
       privateKey = privateKey.slice(1, -1);
    } else if (privateKey.startsWith("'") && privateKey.endsWith("'")) {
       privateKey = privateKey.slice(1, -1);
    }
    // Replace escaped newlines with actual newlines
    privateKey = privateKey.replace(/\\n/g, '\n');

    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: privateKey,
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
