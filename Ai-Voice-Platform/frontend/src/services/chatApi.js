const API_URL = "http://localhost:3000";

export async function sendMessageStream(
    message,
    onChunk,
    sessionId = "demo-session"
) {

    const response = await fetch(`${API_URL}/chat/stream`, {

        method: "POST",

        headers: {
            "Content-Type": "application/json"
        },

        body: JSON.stringify({
            session_id: sessionId,
            message
        })

    });

    if (!response.ok) {
        throw new Error("Failed to send message");
    }

    const reader = response.body.getReader();

    const decoder = new TextDecoder();

    while (true) {

        const { done, value } = await reader.read();

        if (done) {
            break;
        }

        const chunk = decoder.decode(value);

        onChunk(chunk);

    }

}