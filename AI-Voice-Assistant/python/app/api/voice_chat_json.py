from fastapi import APIRouter, UploadFile, File, Form
from app.services.voice_service import VoiceService

router = APIRouter()

voice_service = VoiceService()


@router.post("/voice-chat-json")
async def voice_chat_json(
    session_id: str = Form(...),
    file: UploadFile = File(...)
):
    result = await voice_service.process_voice(
        session_id,
        file
    )

    return result