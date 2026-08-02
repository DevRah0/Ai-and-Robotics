from fastapi import APIRouter, UploadFile, File
from app.services.voice_service import VoiceService
from fastapi.responses import FileResponse

router = APIRouter()

voice_service = VoiceService()


@router.post("/voice-chat")
async def voice_chat(file: UploadFile = File(...)):
    result = await voice_service.process_voice(file)

    return FileResponse(
        path=result["audio_path"],
        media_type="audio/wav",
        filename="response.wav"
)