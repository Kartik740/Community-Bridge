/**
 * Formats survey responses.
 *
 * @param {Array} docs - Firestore documents
 * @returns {Array} - Array of formatted responses
 */
const formatResponses = (docs) => {
  return docs.map(doc => {
    const data = doc.data();
    return {
      id: doc.id,
      ...data,
      submittedAt: data.submittedAt ? (typeof data.submittedAt.toDate === 'function' ? data.submittedAt.toDate() : data.submittedAt) : null,
      syncedAt: data.syncedAt ? (typeof data.syncedAt.toDate === 'function' ? data.syncedAt.toDate() : data.syncedAt) : null
    };
  });
};

module.exports = { formatResponses };
