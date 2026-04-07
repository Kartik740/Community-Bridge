const express = require('express');
const router = express.Router();
const analysisController = require('../controllers/analysisController');

/**
 * POST /api/analyse/:orgId
 * Triggers AI analysis for all approved responses for an org.
 */
router.post('/:orgId', analysisController.runAnalysis);

module.exports = router;
