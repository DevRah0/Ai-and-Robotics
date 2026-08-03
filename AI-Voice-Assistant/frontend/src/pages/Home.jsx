import "../styles/home.css";

import Header from "../components/Header/Header";
import Sidebar from "../components/Sidebar/Sidebar";

import ChatWindow from "../components/ChatWindow/ChatWindow";
import MessageInput from "../components/MessageInput/MessageInput";

import useChat from "../hooks/useChat";

function Home() {

    const { messages, loading, sendMessage } = useChat();

    return (

        <div className="home-container">

            <Header />

            <div className="layout">

                <Sidebar />

                <div className="content">

                    <main className="home-main">

                        <ChatWindow
                            messages={messages}
                            loading={loading}
                        />

                    </main>

                    <footer className="home-footer">

                        <MessageInput
                            onSend={sendMessage}
                            loading={loading}
                        />

                    </footer>

                </div>

            </div>

        </div>

    );

}

export default Home;