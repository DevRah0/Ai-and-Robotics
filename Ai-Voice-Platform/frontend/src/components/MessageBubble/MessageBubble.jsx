import "./MessageBubble.css";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";

function MessageBubble({ role, content }) {
  return (
    <div className={`message-row ${role}`}>
      <div className={`message-bubble ${role}`}>
        {role === "assistant" ? (
          <ReactMarkdown remarkPlugins={[remarkGfm]}>
            {content}
          </ReactMarkdown>
        ) : (
          content
        )}
      </div>
    </div>
  );
}

export default MessageBubble;