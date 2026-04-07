require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

// Initialize Express
const app = express();
const PORT = process.env.PORT || 8080;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Routes
app.use('/api/analyse', require('./routes/analysis'));
app.use('/api/match', require('./routes/matching'));
app.use('/api/notify', require('./routes/notifications'));

// Load Cron Jobs
require('./jobs/scheduledAnalysis');

// Health Check
/**
 * GET /api/health
 * Simple health check API.
 */
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Start Server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

module.exports = app;
