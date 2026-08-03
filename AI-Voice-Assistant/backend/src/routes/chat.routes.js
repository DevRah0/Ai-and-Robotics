const express = require("express");
const router = express.Router();

const {
    ask,
    askStream
} = require("../services/pythonClient");

router.post("/", async (req, res) => {

    try {

        const { session_id, message } = req.body;

        if (!message) {
            return res.status(400).json({
                error: "Message is required"
            });
        }

        const reply = await ask(
            session_id || "default-session",
            message
        );

        res.json({
            reply
        });

    } catch (error) {

        console.error(error);

        res.status(500).json({
            error: "Failed to generate response"
        });

    }

});


router.post("/stream", async (req, res) => {

    try {

        const { session_id, message } = req.body;

        const stream = await askStream(
            session_id || "default-session",
            message
        );

        res.setHeader("Content-Type", "text/plain; charset=utf-8");
        res.setHeader("Transfer-Encoding", "chunked");

        stream.pipe(res);

    } catch (error) {

        console.error(error);

        res.status(500).end();

    }

});


module.exports = router;