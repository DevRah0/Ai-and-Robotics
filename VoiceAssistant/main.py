"""
Desktop Voice Assistant

A simple desktop GUI application that:
  Rec. -> Whisper STT -> Gemini API -> gTTS TTS -> pygame playback
  and shows both the user's transcript and the AI response in the window.

Run:
    python main.py
"""

import os
import threading
import tempfile

import tkinter as tk
from tkinter import scrolledtext

from dotenv import load_dotenv

# ---------------------------------------------------------------------------
# Optional imports are done lazily inside the worker so that a missing optional
# dependency produces a friendly in-window error instead of a startup crash.
# ---------------------------------------------------------------------------


def _safe_import(module_name: str):
    """Import a module lazily; return None instead of raising."""
    try:
        return __import__(module_name)
    except Exception:  # noqa: BLE001 - any import failure is turned into None
        return None


# Load environment variables from .env (API key lives here, never in source).
load_dotenv()

GEMINI_API_KEY_ENV = "GEMINI_API_KEY"
API_KEY = os.getenv(GEMINI_API_KEY_ENV, "").strip()

# Paths for temporary audio files.
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
AUDIO_DIR = os.path.join(BASE_DIR, "audio")
TEMP_WAV = os.path.join(AUDIO_DIR, "temp.wav")
OUTPUT_MP3 = os.path.join(AUDIO_DIR, "output.mp3")


class VoiceAssistantApp:
    """Tkinter desktop application for the voice assistant."""

    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("Voice Assistant")
        self.root.geometry("640x560")
        self.root.minsize(520, 480)

        # Worker state.
        self._recording = False
        self._frames: list[bytes] = []
        self._sample_rate = 16000

        self._build_ui()

    # ----------------------------------------------------------------- UI
    def _build_ui(self) -> None:
        container = tk.Frame(self.root, padx=24, pady=20)
        container.pack(fill="both", expand=True)

        title = tk.Label(
            container,
            text="Voice Assistant",
            font=("Segoe UI", 20, "bold"),
        )
        title.pack(pady=(0, 16))

        self.status_var = tk.StringVar(value="Ready")
        status_label = tk.Label(
            container,
            textvariable=self.status_var,
            font=("Segoe UI", 12),
            fg="#2563eb",
        )
        status_label.pack(pady=(0, 12))

        self.record_btn = tk.Button(
            container,
            text="🎤 Start Recording",
            font=("Segoe UI", 13),
            command=self.toggle_recording,
            height=2,
            width=24,
        )
        self.record_btn.pack(pady=(0, 16))

        sep = tk.Frame(container, height=2, bg="#e5e7eb")
        sep.pack(fill="x", pady=8)

        you_label = tk.Label(container, text="You:", font=("Segoe UI", 11, "bold"))
        you_label.pack(anchor="w")
        self.you_text = scrolledtext.ScrolledText(
            container, height=5, wrap="word", font=("Segoe UI", 11)
        )
        self.you_text.pack(fill="x", pady=(2, 10))

        ai_label = tk.Label(container, text="AI:", font=("Segoe UI", 11, "bold"))
        ai_label.pack(anchor="w")
        self.ai_text = scrolledtext.ScrolledText(
            container, height=8, wrap="word", font=("Segoe UI", 11)
        )
        self.ai_text.pack(fill="both", expand=True, pady=(2, 0))

    # ----------------------------------------------------------- Helpers
    def _set_status(self, text: str) -> None:
        """Update the status label from any thread (GUI-safe)."""
        self.root.after(0, lambda: self.status_var.set(text))

    def _append_text(self, widget, text: str) -> None:
        """Append text to a text widget and scroll to bottom (GUI-safe)."""
        def _do():
            widget.configure(state="normal")
            widget.insert("end", text + "\n")
            widget.configure(state="disabled")
            widget.see("end")

        self.root.after(0, _do)

    def _clear_text(self, widget) -> None:
        def _do():
            widget.configure(state="normal")
            widget.delete("1.0", "end")
            widget.configure(state="disabled")

        self.root.after(0, _do)

    def _busy(self, busy: bool) -> None:
        """Enable/disable the record button (GUI-safe)."""
        state = "disabled" if busy else "normal"
        self.root.after(0, lambda: self.record_btn.configure(state=state))

    # ----------------------------------------------------- Recording
    def toggle_recording(self) -> None:
        if self._recording:
            self.stop_recording()
        else:
            self.start_recording()

    def start_recording(self) -> None:
        # Imported lazily so a friendly error is shown if missing.
        sounddevice = _safe_import("sounddevice")
        if sounddevice is None:
            self._set_status("Error: sounddevice not installed")
            self._append_text(self.ai_text, "Mic unavailable: install sounddevice.")
            return

        self._clear_text(self.you_text)
        self._clear_text(self.ai_text)
        self._recording = True
        self._frames = []
        self._set_status("Recording…")
        self.record_btn.configure(text="🛑 Stop Recording")
        self._busy(True)

        threading.Thread(target=self._record_loop, args=(sounddevice,), daemon=True).start()

    def _record_loop(self, sounddevice) -> None:
        try:
            # Default input device; if none exists, error is raised and handled.
            with sounddevice.InputStream(
                samplerate=self._sample_rate,
                channels=1,
                dtype="int16",
            ) as stream:
                while self._recording:
                    data, _overflowed = stream.read(1024)
                    self._frames.append(data)
        except Exception as exc:  # noqa: BLE001 - show friendly error to user
            self._set_status("Microphone unavailable")
            self._append_text(
                self.ai_text,
                f"Mic error: {exc}\nConnect a microphone and try again.",
            )
            self._recording = False
            self._busy(False)
            self.record_btn.configure(text="🎤 Start Recording")

    def stop_recording(self) -> None:
        self._recording = False
        self._set_status("Processing…")
        self.record_btn.configure(text="🎤 Start Recording")
        self._busy(True)

        threading.Thread(target=self._process_recording, daemon=True).start()

    # ------------------------------------------------------- Pipeline
    def _process_recording(self) -> None:
        try:
            if not self._frames:
                self._set_status("Ready")
                self._append_text(self.ai_text, "No audio captured.")
                self._busy(False)
                return

            # 1) Write the recorded frames to a WAV file using scipy.
            scipy = _safe_import("scipy.io.wavfile")
            if scipy is None:
                self._set_status("Error: scipy not installed")
                self._busy(False)
                return

            os.makedirs(AUDIO_DIR, exist_ok=True)
            import numpy as np

            audio = np.concatenate(self._frames, axis=0)
            scipy.write(TEMP_WAV, self._sample_rate, audio)

            # 2) Transcribe with Whisper.
            transcript = self._transcribe()
            if not transcript:
                self._set_status("Ready")
                self._append_text(self.you_text, "[No speech detected]")
                self._busy(False)
                return

            self._append_text(self.you_text, transcript)

            # 3) Ask Gemini.
            self._set_status("Generating response…")
            reply = self._ask_gemini(transcript)
            self._append_text(self.ai_text, reply)

            # 4) Synthesize speech and play it.
            self._set_status("Playing response…")
            self._play_audio(reply)

        except Exception as exc:  # noqa: BLE001 - never crash unexpectedly
            self._set_status("Error")
            self._append_text(self.ai_text, f"Unexpected error: {exc}")
        finally:
            self._set_status("Ready")
            self._busy(False)

    def _transcribe(self) -> str:
        self._set_status("Processing…")
        try:
            import whisper

            model = whisper.load_model("base")
            result = model.transcribe(TEMP_WAV)
            return (result.get("text") or "").strip()
        except Exception as exc:  # noqa: BLE001
            self._set_status("Error")
            self._append_text(self.ai_text, f"Whisper failed: {exc}")
            return ""

    def _ask_gemini(self, prompt: str) -> str:
        if not API_KEY:
            self._set_status("Error: API key missing")
            return (
                "API key is missing.\n\n"
                "1. Copy .env.example to .env\n"
                "2. Put your Gemini API key in GEMINI_API_KEY=...\n"
                "3. Restart the app."
            )

        genai = _safe_import("google.genai")
        if genai is None:
            return "Gemini library not installed (add google-genai to requirements)."

        client = genai.Client(api_key=API_KEY)
        try:
            response = client.models.generate_content(
                model="gemini-2.0-flash",
                contents=prompt,
            )
            return (response.text or "").strip() or "(Empty response)"
        except Exception as exc:  # noqa: BLE001
            self._set_status("Error")
            return f"Gemini error: {exc}"

    def _play_audio(self, text: str) -> None:
        try:
            from gtts import gTTS
        except Exception:  # noqa: BLE001
            self._append_text(self.ai_text, "(gTTS not installed — audio skipped)")
            return

        try:
            tts = gTTS(text=text, lang="en")
            tts.save(OUTPUT_MP3)
        except Exception as exc:  # noqa: BLE001
            self._append_text(self.ai_text, f"TTS failed: {exc}")
            return

        pygame = _safe_import("pygame")
        if pygame is None:
            return

        try:
            pygame.mixer.init()
            pygame.mixer.music.load(OUTPUT_MP3)
            pygame.mixer.music.play()
            while pygame.mixer.music.get_busy():
                pygame.time.wait(50)
            pygame.mixer.quit()
        except Exception as exc:  # noqa: BLE001
            self._append_text(self.ai_text, f"Playback failed: {exc}")


def main() -> None:
    root = tk.Tk()
    app = VoiceAssistantApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
