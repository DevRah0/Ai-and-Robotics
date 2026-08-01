const express = require("express");
const router = express.Router();

const { ask } = require("../services/llm/providerManager");

router.post("/", async (req, res) => {

    try {

        const { message } = req.body;

        if (!message) {
            return res.status(400).json({
                error: "Message is required"
            });
        }

        const reply = await ask(message);

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

module.exports = router;