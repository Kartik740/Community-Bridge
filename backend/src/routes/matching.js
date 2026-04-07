const express = require('express');
const router = express.Router();
const matchingController = require('../controllers/matchingController');

/**
 * POST /api/match/:taskId
 * Triggers the volunteer matching algorithm for a specific task.
 */
router.post('/:taskId', matchingController.matchTask);

module.exports = router;
