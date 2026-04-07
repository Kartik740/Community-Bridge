const fs = require('fs');
require('dotenv').config();

async function listModels() {
  try {
    const key = process.env.GEMINI_API_KEY;
    const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${key}`;
    const response = await fetch(url);
    const data = await response.json();
    
    if (data.error) {
       fs.writeFileSync('models.json', JSON.stringify({error: data.error}, null, 2));
    } else {
       const names = data.models.map(m => m.name);
       fs.writeFileSync('models.json', JSON.stringify(names, null, 2));
    }
  } catch (error) {
    fs.writeFileSync('models.json', JSON.stringify({error: error.message}, null, 2));
  }
}
listModels();
