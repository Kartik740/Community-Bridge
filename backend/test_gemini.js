require('dotenv').config();
const { GoogleGenerativeAI } = require("@google/generative-ai");

async function test() {
  try {
    const key = process.env.GEMINI_API_KEY;
    console.log("Using Key ending in:", key ? key.slice(-4) : "UNDEFINED");
    const genAI = new GoogleGenerativeAI(key);
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });
    const result = await model.generateContent("Hello, are you working? Please just reply 'YES'.");
    console.log("Gemini Response:", result.response.text());
  } catch (error) {
    console.error("=== ERROR MESSAGE ===");
    console.error(error.message);
  }
}
test();
