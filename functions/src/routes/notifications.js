const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');

/**
 * POST /api/notify/:taskId/:volunteerId
 * Sends an FCM push notification to the volunteer.
 */
router.post('/:taskId/:volunteerId', notificationController.notifyVolunteer);

module.exports = router;
