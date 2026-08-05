from fastapi import APIRouter
from fastapi.responses import FileResponse
from pydantic import BaseModel

from app.services.tts_service import TTSService

router = APIRouter()

tts_service = TTSService()


class TTSRequest(BaseModel):
    text: str


@router.post("/tts")
async def tts(request: TTSRequest):
    output_file = "output.wav"

    tts_service.synthesize(
        text=request.text,
        output_file=output_file
    )

    return FileResponse(
        output_file,
        media_type="audio/wav",
        filename="output.wav"
    )