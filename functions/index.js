const functions = require("firebase-functions");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.moodMateAI = functions.https.onRequest(async (req, res) => {
  try {
    const mood = req.body.mood;

    if (!mood) {
      return res.status(400).json({ error: "Mood is required" });
    }

    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    const result = await model.generateContent(
      `Saya sedang merasa ${mood}. Tolong beri motivasi singkat.`
    );

    res.json({
      text: result.response.text(),
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: error.toString() });
  }
});
