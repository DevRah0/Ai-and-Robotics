import "./Header.css";

function Header() {
  return (
    <header className="header">
      <div className="header-left">
        <div className="logo">🤖</div>

        <div>
          <h1>AI Voice Assistant</h1>
          <p>Your intelligent voice companion</p>
        </div>
      </div>

      <div className="header-right">
        <button className="settings-btn">
          ⚙️
        </button>
      </div>
    </header>
  );
}

export default Header;