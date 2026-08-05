window.onload = async () => {

    try {

        const result = await healthCheck();

        console.log(result);

        const chat = document.getElementById("chatContainer");

        chat.innerHTML = `
            <div class="message">
                <strong>System</strong>
                <p>${result.message}</p>
            </div>
        `;

        const sendBtn = document.getElementById("sendBtn");
        const input = document.getElementById("messageInput");

        sendBtn.addEventListener("click", async () => {

            const message = input.value.trim();

            if (!message) return;

            chat.innerHTML += `
                <div class="message">
                    <strong>You</strong>
                    <p>${message}</p>
                </div>
            `;

            const response = await sendMessage(message);

            chat.innerHTML += `
                <div class="message">
                    <strong>Assistant</strong>
                    <p>${response.reply}</p>
                </div>
            `;

            input.value = "";

        });

    } catch (error) {

        console.error(error);

        alert("Backend Offline");

    }

};