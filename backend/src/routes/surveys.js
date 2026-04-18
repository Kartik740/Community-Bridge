const express = require('express');
const router = express.Router();
const { deleteSurvey } = require('../controllers/surveysController');

router.post('/delete', deleteSurvey);

module.exports = router;
