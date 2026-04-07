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
      submittedAt: data.submittedAt ? data.submittedAt.toDate() : null,
      syncedAt: data.syncedAt ? data.syncedAt.toDate() : null
    };
  });
};

module.exports = { formatResponses };
