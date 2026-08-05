const axios = require("axios");

const PYTHON_API = process.env.PYTHON_API || "http://127.0.0.1:8000";

async function ask(sessionId, message) {
    const response = await axios.post(`${PYTHON_API}/chat`, {
        session_id: sessionId,
        message: message
    });

    return response.data.reply;
}

async function askStream(sessionId, message) {

    const response = await axios.post(
        `${PYTHON_API}/chat-stream`,
        {
            session_id: sessionId,
            message: message
        },
        {
            responseType: "stream"
        }
    );

    return response.data;
}

module.exports = {
    ask,
    askStream
};