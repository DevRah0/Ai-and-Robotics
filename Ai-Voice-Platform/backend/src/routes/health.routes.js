const express = require("express");

const router = express.Router();

router.get("/", (req, res) => {
    res.status(200).json({
        success: true,
        message: "AI Voice Assistant Backend is running",
        version: "1.0.0"
    });
});
router.post("/chat", (req, res) => {

    const { message } = req.body;

    res.json({
        reply: `You said: ${message}`
    });

});

module.exports = router;