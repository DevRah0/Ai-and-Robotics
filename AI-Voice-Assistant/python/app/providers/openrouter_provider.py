import os
import httpx
from dotenv import load_dotenv

load_dotenv()


class OpenRouterProvider:

    def __init__(self):
        self.api_key = os.getenv("OPENROUTER_API_KEY")
        self.model = os.getenv("OPENROUTER_MODEL")
        self.base_url = "https://openrouter.ai/api/v1/chat/completions"

    async def generate(self, message: str):

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost:8000",
            "X-Title": "AI Voice Assistant"
        }

        payload = {
            "model": self.model,
            "messages": [
                {
                    "role": "user",
                    "content": message
                }
            ]
        }

        async with httpx.AsyncClient(timeout=60.0) as client:
            response = await client.post(
                self.base_url,
                headers=headers,
                json=payload
            )

            response.raise_for_status()

            data = response.json()

            return data["choices"][0]["message"]["content"]