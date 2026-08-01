const axios = require("axios");

const API_KEY = process.env.OPENROUTER_API_KEY;
const MODEL = process.env.OPENROUTER_MODEL;

async function askLLM(message, model) {

    try {

        const response = await axios.post(
            "https://openrouter.ai/api/v1/chat/completions",
            {
                model: model,
                messages: [
                    {
                        role: "user",
                        content: message
                    }
                ]
            },
            {
                headers: {
                    Authorization: `Bearer ${API_KEY}`,
                    "Content-Type": "application/json"
                }
            }
        );

        return response.data.choices[0].message.content;

    } catch (error) {

        console.error(error.response?.data || error.message);

        throw new Error("LLM request failed");

    }

}

module.exports = {
    askLLM
};