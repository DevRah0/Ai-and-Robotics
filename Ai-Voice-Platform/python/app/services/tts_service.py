from app.providers.piper_provider import PiperProvider


class TTSService:
    def __init__(self):
        self.provider = PiperProvider()

    from app.providers.piper_provider import PiperProvider


class TTSService:
    def __init__(self):
        self.provider = PiperProvider()

    def synthesize(self, text: str, output_file: str = "output.wav"):
        return self.provider.synthesize(
            text=text,
            output_file=output_file
        )