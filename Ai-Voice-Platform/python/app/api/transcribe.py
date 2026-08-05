from fastapi import APIRouter, UploadFile, File, HTTPException

from app.services.speech_service import SpeechService

router = APIRouter()

speech_service = SpeechService()


@router.post("/transcribe")
async def transcribe(file: UploadFile = File(...)):
    try:
        result = await speech_service.transcribe(file)
        return result

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=str(e)
        )