import os
import json
import httpx
from dotenv import load_dotenv

load_dotenv()


class OpenRouterProvider:

    def __init__(self):
        self.api_key = os.getenv("OPENROUTER_API_KEY")
        self.model = os.getenv("OPENROUTER_MODEL")
        self.base_url = "https://openrouter.ai/api/v1/chat/completions"

    async def generate(self, messages: list):

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost:8000",
            "X-Title": "AI Voice Assistant"
        }

        system_message = {
            "role": "system",
            "content": (
                "You are a helpful AI voice assistant. "
                "Remember the conversation context and answer naturally."
            )
        }

        conversation = [system_message] + messages

        payload = {
            "model": self.model,
            "messages": conversation
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

    async def stream_generate(self, messages: list):

        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost:8000",
            "X-Title": "AI Voice Assistant"
        }

        system_message = {
            "role": "system",
            "content": (
                "You are a helpful AI voice assistant. "
                "Remember the conversation context and answer naturally."
            )
        }

        conversation = [system_message] + messages

        payload = {
            "model": self.model,
            "messages": conversation,
            "stream": True
        }

        async with httpx.AsyncClient(timeout=None) as client:

            async with client.stream(
                "POST",
                self.base_url,
                headers=headers,
                json=payload
            ) as response:

                response.raise_for_status()

                async for line in response.aiter_lines():

                    if not line:
                        continue

                    if not line.startswith("data: "):
                        continue

                    data = line[6:]

                    if data == "[DONE]":
                        break

                    try:
                        chunk = json.loads(data)

                        delta = chunk["choices"][0]["delta"]

                        content = delta.get("content")

                        if content:
                            yield content

                    except Exception:
                        continue