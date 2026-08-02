from app.providers.openrouter_provider import OpenRouterProvider


class ChatService:

    def __init__(self):
        self.provider = OpenRouterProvider()

    async def generate_reply(self, message: str) -> str:
        return await self.provider.generate(message)