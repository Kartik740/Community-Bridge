const express = require('express');
const router = express.Router();
const { deleteResponses } = require('../controllers/responsesController');

router.post('/delete', deleteResponses);

module.exports = router;
