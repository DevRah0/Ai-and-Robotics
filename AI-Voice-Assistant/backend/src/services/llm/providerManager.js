const MODELS = require("./models");
const { askLLM } = require("../llm.service");

async function ask(message) {

    for (const model of MODELS) {

        try {

            const reply = await askLLM(message, model);

            return reply;

        } catch (error) {

            console.log(`Model Failed: ${model}`);

        }

    }

    throw new Error("All models failed.");

}

module.exports = {
    ask
};