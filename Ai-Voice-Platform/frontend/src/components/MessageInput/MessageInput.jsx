import { useState } from "react";
import "./MessageInput.css";

function MessageInput({ onSend, loading }) {
  const [text, setText] = useState("");

  function handleSubmit(e) {
    e.preventDefault();

    if (!text.trim()) return;

    onSend(text);
    setText("");
  }

  return (
    <form className="message-form" onSubmit={handleSubmit}>
      <input
        className="message-input"
        type="text"
        placeholder="Type your message..."
        value={text}
        onChange={(e) => setText(e.target.value)}
        disabled={loading}
      />

      <button
        className="send-button"
        type="submit"
        disabled={loading}
      >
        {loading ? "Sending..." : "Send"}
      </button>
    </form>
  );
}

export default MessageInput;