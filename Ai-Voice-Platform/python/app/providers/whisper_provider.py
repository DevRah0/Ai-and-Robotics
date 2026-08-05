from faster_whisper import WhisperModel
import tempfile
import os
import os
from dotenv import load_dotenv

load_dotenv()

class WhisperProvider:
    def __init__(self):
        self.model = WhisperModel(
    os.getenv("WHISPER_MODEL", "base"),
    device=os.getenv("WHISPER_DEVICE", "cpu"),
    compute_type=os.getenv("WHISPER_COMPUTE_TYPE", "int8")
)

    async def transcribe(self, file):
        audio = await file.read()

        with tempfile.NamedTemporaryFile(
            delete=False,
            suffix=".wav"
        ) as temp_file:
            temp_file.write(audio)
            temp_path = temp_file.name

        try:
            segments, info = self.model.transcribe(temp_path)

            text = ""

            for segment in segments:
                text += segment.text

            return text.strip()

        finally:
            if os.path.exists(temp_path):
                os.remove(temp_path)

    def test_model(self):
        return "Whisper loaded successfully!"