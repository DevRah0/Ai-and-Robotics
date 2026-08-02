from app.services.speech_service import SpeechService
from app.services.chat_service import ChatService
from app.services.tts_service import TTSService


class VoiceService:
    def __init__(self):
        self.speech_service = SpeechService()
        self.chat_service = ChatService()
        self.tts_service = TTSService()

    async def process_voice(self, audio_file):
        # 1. تحويل الصوت إلى نص
        text = await self.speech_service.transcribe(audio_file)

        # 2. إرسال النص إلى نموذج الذكاء الاصطناعي
        reply = await self.chat_service.generate_reply(text)

        # 3. تحويل الرد إلى صوت
        audio_path = self.tts_service.synthesize(reply)

        return {
            "text": text,
            "reply": reply,
            "audio_path": audio_path,
        }