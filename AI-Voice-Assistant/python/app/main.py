from fastapi import FastAPI
from app.api.chat import router as chat_router
from app.api.transcribe import router as transcribe_router
from app.api.tts import router as tts_router
from app.api.voice_chat import router as voice_chat_router

app = FastAPI(
    title="AI Voice Assistant",
    version="1.0.0"
)

app.include_router(chat_router)
app.include_router(transcribe_router)
app.include_router(tts_router)
app.include_router(voice_chat_router)

@app.get("/")
async def root():
    return {
        "service": "AI Python Service",
        "status": "running"
    }