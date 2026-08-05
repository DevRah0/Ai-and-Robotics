from pydantic import BaseModel


class SpeechResponse(BaseModel):
    text: str