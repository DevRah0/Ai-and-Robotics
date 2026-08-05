import { useState } from "react";
import { sendMessageStream } from "../services/chatApi";

export default function useChat() {

    const [messages, setMessages] = useState([]);

    const [loading, setLoading] = useState(false);

    async function sendMessage(text) {

        if (!text.trim()) return;

       const assistantId = crypto.randomUUID();

const userMessage = {
    id: crypto.randomUUID(),
    role: "user",
    content: text
};

const assistantMessage = {
    id: assistantId,
    role: "assistant",
    content: ""
};

 setMessages(prev => [
    ...prev,
    userMessage,
    assistantMessage
]);

setLoading(true);
        try {

            await sendMessageStream(

                text,

                (chunk) => {

                    setMessages(prev =>
    prev.map(message =>
        message.id === assistantId
            ? {
                ...message,
                content: message.content + chunk
            }
            : message
    )
);

                }

            );

        }

        catch (error) {

            console.error(error);

        }

        finally {

            setLoading(false);

        }

    }

    return {

        messages,
        loading,
        sendMessage

    };

}