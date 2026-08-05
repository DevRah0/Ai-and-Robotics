const express = require("express");
const cors = require("cors");

const healthRoutes = require("./routes/health.routes");
const chatRoutes = require("./routes/chat.routes");

const app = express();

app.use(cors());
app.use(express.json());

app.use("/health", healthRoutes);
app.use("/chat", chatRoutes);

module.exports = app;