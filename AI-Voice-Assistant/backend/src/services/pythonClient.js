const axios = require("axios");

const PYTHON_API = process.env.PYTHON_API || "http://127.0.0.1:8000";

async function ask(message) {
    const response = await axios.post(`${PYTHON_API}/chat`, {
        message
    });

    return response.data.reply;
}

module.exports = {
    ask
};