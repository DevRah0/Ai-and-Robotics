from app.providers.openrouter_provider import OpenRouterProvider
from app.services.memory_service import memory_service


class ChatService:

    def __init__(self):
        self.provider = OpenRouterProvider()
        self.memory = memory_service

    async def generate_reply(self, session_id: str, message: str):

        self.memory.add_user_message(session_id, message)

        history = self.memory.get_history(session_id)

        reply = await self.provider.generate(history)

        self.memory.add_assistant_message(session_id, reply)

        return reply

    async def generate_reply_stream(self, session_id: str, message: str):

        self.memory.add_user_message(session_id, message)

        history = self.memory.get_history(session_id)

        full_reply = ""

        async for chunk in self.provider.stream_generate(history):

            full_reply += chunk

            yield chunk

        self.memory.add_assistant_message(
            session_id,
            full_reply
        )