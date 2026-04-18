const { calculateDistance } = require('../utils/distanceCalculator');

/**
 * Service to score and match volunteers based on task requirements
 * 
 * @param {Object} task - Task document data
 * @param {Array} volunteers - Array of volunteer documents
 * @returns {Array} Top 3 matching volunteer IDs
 */
const matchVolunteers = (task, volunteers) => {
  const scoredVolunteers = volunteers.map(volunteer => {
    let score = 0;

    // 1. Skill Score (Max 40 points)
    const taskSkills = task.requiredSkills || [];
    const volunteerSkills = volunteer.skills || [];
    if (taskSkills.length > 0) {
      const matchedSkills = volunteerSkills.filter(skill => taskSkills.includes(skill));
      score += (matchedSkills.length / taskSkills.length) * 40;
    } else {
        score += 40; // Full score if no skills required
    }

    // 2. Proximity Score (Max 40 points)
    let proximityScore = 0;
    if (volunteer.location && task.location) {
        const distance = calculateDistance(
          task.location.lat, task.location.lng,
          volunteer.location.lat, volunteer.location.lng
        );
        
        if (distance < 5) proximityScore = 40;
        else if (distance < 15) proximityScore = 25;
        else if (distance < 30) proximityScore = 10;
        else proximityScore = 0;
    }
    score += proximityScore;

    // 3. Availability Score (Max 20 points)
    if (volunteer.availability === true) {
      score += 20;
    }

    return {
      id: volunteer.id,
      score: score
    };
  });

  // Sort descending by score
  scoredVolunteers.sort((a, b) => b.score - a.score);

  // Return top 3 volunteer IDs
  return scoredVolunteers.slice(0, 3).map(v => v.id);
};

module.exports = { matchVolunteers };
