const API_URL = "http://localhost:3000";

async function healthCheck() {

    const response = await fetch(`${API_URL}/health`);

    return await response.json();

}
async function sendMessage(message) {

    const response = await fetch(`${API_URL}/health/chat`, {

        method: "POST",

        headers: {
            "Content-Type": "application/json"
        },

        body: JSON.stringify({
            message: message
        })

    });

    return await response.json();

}