from fastapi import APIRouter
from fastapi.responses import StreamingResponse

from app.services.memory_service import memory_service
from app.models.chat import ChatRequest, ChatResponse
from app.services.chat_service import ChatService

router = APIRouter()
service = ChatService()


@router.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):

    reply = await service.generate_reply(
        request.session_id,
        request.message
    )

    return ChatResponse(reply=reply)


@router.post("/chat-stream")
async def chat_stream(request: ChatRequest):

    async def event_generator():

        async for chunk in service.generate_reply_stream(
            request.session_id,
            request.message
        ):
            yield chunk

    return StreamingResponse(
        event_generator(),
        media_type="text/plain"
    )


@router.delete("/memory/{session_id}")
async def clear_memory(session_id: str):

    memory_service.clear(session_id)

    return {
        "message": f"Memory for session '{session_id}' has been cleared."
    }