import "./Sidebar.css";

function Sidebar() {
  return (
    <aside className="sidebar">

      <button className="new-chat-btn">
        + New Chat
      </button>

      <div className="chat-history">

        <div className="chat-item active">
          💬 Current Chat
        </div>

        <div className="chat-item">
          💬 Conversation 2
        </div>

        <div className="chat-item">
          💬 Conversation 3
        </div>

      </div>

    </aside>
  );
}

export default Sidebar;