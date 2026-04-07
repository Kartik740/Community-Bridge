require('dotenv').config();

async function listModels() {
  try {
    const key = process.env.GEMINI_API_KEY;
    const url = `https://generativelanguage.googleapis.com/v1beta/models?key=${key}`;
    const response = await fetch(url);
    const data = await response.json();
    
    if (data.error) {
       console.log("API Error:", data.error);
    } else {
       console.log("Models found:");
       data.models.forEach(m => {
          if (m.name.includes('gemini')) console.log(' - ' + m.name);
       });
    }
  } catch (error) {
    console.error(error);
  }
}
listModels();
