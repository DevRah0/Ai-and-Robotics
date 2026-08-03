import { useEffect, useRef } from "react";
import "./ChatWindow.css";
import MessageBubble from "../MessageBubble/MessageBubble";

function ChatWindow({ messages, loading }) {
  const bottomRef = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({
      behavior: "smooth",
    });
  }, [messages]);

  return (
    <div className="chat-window">
      <div className="chat-container">
        {messages.length === 0 ? (
          <p>No messages yet.</p>
        ) : (
          messages.map((message, index) => (
            <MessageBubble
              key={index}
              role={message.role}
              content={message.content}
            />
          ))
        )}
{loading && (
  <MessageBubble
    role="assistant"
    content="AI is typing..."
  />
)}
        <div ref={bottomRef}></div>
      </div>
    </div>
  );
}

export default ChatWindow;