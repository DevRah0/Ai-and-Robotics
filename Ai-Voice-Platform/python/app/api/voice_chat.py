from fastapi import APIRouter, UploadFile, File, Form
from app.services.voice_service import VoiceService
from fastapi.responses import FileResponse

router = APIRouter()

voice_service = VoiceService()


@router.post("/voice-chat")
async def voice_chat(
    session_id: str = Form(...),
    file: UploadFile = File(...)
):
    result = await voice_service.process_voice(
        session_id,
        file
    )

    return FileResponse(
        path=result["audio_path"],
        media_type="audio/wav",
        filename="response.wav"
    )