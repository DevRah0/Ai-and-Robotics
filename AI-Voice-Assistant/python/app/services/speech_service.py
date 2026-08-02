from app.providers.whisper_provider import WhisperProvider


class SpeechService:
    def __init__(self):
        self.provider = WhisperProvider()

    async def transcribe(self, file):
        return await self.provider.transcribe(file)