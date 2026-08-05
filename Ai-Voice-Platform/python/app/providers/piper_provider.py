from pathlib import Path
import subprocess
import tempfile


class PiperProvider:
    def __init__(self):
        self.project_root = Path(__file__).resolve().parents[2]

        self.piper_path = (
            self.project_root /
            "tools" /
            "piper" /
            "piper.exe"
        )

        self.model_path = (
            self.project_root /
            "app" /
            "models" /
            "piper" /
            "en_US-lessac-medium.onnx"
        )

    def test(self):
        return {
            "piper": str(self.piper_path),
            "model": str(self.model_path)
        }

    def synthesize(self, text: str, output_file: str = "output.wav"):
        if output_file == "output.wav":
            temp_file = tempfile.NamedTemporaryFile(
                suffix=".wav",
                delete=False
            )
            output_file = temp_file.name
            temp_file.close()

        command = [
            str(self.piper_path),
            "-m",
            str(self.model_path),
            "-f",
            output_file
        ]

        subprocess.run(
            command,
            input=text,
            text=True,
            check=True
        )

        return output_file