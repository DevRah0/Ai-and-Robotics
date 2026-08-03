from collections import defaultdict


class MemoryService:
    def __init__(self):
        self._memory = defaultdict(list)

    def get_history(self, session_id: str):
        return self._memory[session_id]

    def add_user_message(self, session_id: str, message: str):
        history = self._memory[session_id]

        history.append({
            "role": "user",
            "content": message
        })

        if len(history) > 20:
            del history[0]

    def add_assistant_message(self, session_id: str, message: str):
        history = self._memory[session_id]

        history.append({
            "role": "assistant",
            "content": message
        })

        if len(history) > 20:
            del history[0]

    def clear(self, session_id: str):
        self._memory.pop(session_id, None)


# Shared instance
memory_service = MemoryService()