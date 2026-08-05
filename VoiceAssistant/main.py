"""
Desktop Voice Assistant

Pipeline: record -> Whisper (STT) -> Gemini API -> gTTS (TTS) -> pygame playback.

Design notes:
- The Whisper model is loaded ONCE and reused for every request.
- The pygame mixer is initialized ONCE and reused.
- All UI updates are marshalled to the Tk main loop via `after` (thread-safe);
  worker threads never touch Tk widgets directly.
- A small state machine (idle / recording / processing) prevents races and
  guarantees the user can always Stop a recording.

Run:
    python main.py
"""

import os
import threading
import tempfile

import tkinter as tk
from tkinter import scrolledtext

from dotenv import load_dotenv

load_dotenv()

GEMINI_API_KEY_ENV = "GEMINI_API_KEY"
API_KEY = os.getenv(GEMINI_API_KEY_ENV, "").strip()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Application states.
IDLE = "idle"
RECORDING = "recording"
PROCESSING = "processing"


def _safe_import(module_name):
    """Import a module lazily; return None instead of raising."""
    try:
        return __import__(module_name)
    except Exception:  # noqa: BLE001 - an import failure is treated as missing
        return None


class VoiceAssistantApp:
    """Tkinter desktop application for the voice assistant."""

    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("Voice Assistant")
        self.root.geometry("640x560")
        self.root.minsize(520, 480)

        self._state = IDLE
        self._sample_rate = 16000
        self._frames: list = []

        # Expensive resources loaded lazily exactly once.
        self._whisper_model = None
        self._whisper_lock = threading.Lock()
        self._pygame = None

        self._build_ui()

    # --------------------------------------------------------------- UI
    def _build_ui(self) -> None:
        container = tk.Frame(self.root, padx=24, pady=20)
        container.pack(fill="both", expand=True)

        tk.Label(
            container,
            text="Voice Assistant",
            font=("Segoe UI", 20, "bold"),
        ).pack(pady=(0, 16))

        self.status_var = tk.StringVar(value="Ready")
        tk.Label(
            container,
            textvariable=self.status_var,
            font=("Segoe UI", 12),
            fg="#2563eb",
        ).pack(pady=(0, 12))

        self.record_btn = tk.Button(
            container,
            text="🎤 Start Recording",
            font=("Segoe UI", 13),
            command=self.toggle_recording,
            height=2,
            width=24,
        )
        self.record_btn.pack(pady=(0, 16))

        tk.Frame(container, height=2, bg="#e5e7eb").pack(fill="x", pady=8)

        tk.Label(container, text="You:", font=("Segoe UI", 11, "bold")).pack(anchor="w")
        self.you_text = scrolledtext.ScrolledText(
            container, height=5, wrap="word", font=("Segoe UI", 11)
        )
        self.you_text.pack(fill="x", pady=(2, 10))

        tk.Label(container, text="AI:", font=("Segoe UI", 11, "bold")).pack(anchor="w")
        self.ai_text = scrolledtext.ScrolledText(
            container, height=8, wrap="word", font=("Segoe UI", 11)
        )
        self.ai_text.pack(fill="both", expand=True, pady=(2, 0))

    # ---------------------------------------------- thread-safe UI helpers
    def _set_status(self, text: str) -> None:
        self.root.after(0, lambda: self.status_var.set(text))

    def _set_button_text(self, text: str) -> None:
        self.root.after(0, lambda: self.record_btn.configure(text=text))

    def _set_button_state(self, state: str) -> None:
        self.root.after(0, lambda: self.record_btn.configure(state=state))

    def _append_text(self, widget, text: str) -> None:
        def _do():
            widget.configure(state="normal")
            widget.insert("end", text + "\n")
            widget.configure(state="disabled")
            widget.see("end")

        self.root.after(0, _do)

    def _clear_texts(self) -> None:
        def _do():
            for widget in (self.you_text, self.ai_text):
                widget.configure(state="normal")
                widget.delete("1.0", "end")
                widget.configure(state="disabled")

        self.root.after(0, _do)

    # ---------------------------------------------------------- handler
    def toggle_recording(self) -> None:
        if self._state == RECORDING:
            self.stop_recording()
        elif self._state == IDLE:
            self.start_recording()

    def start_recording(self) -> None:
        sounddevice = _safe_import("sounddevice")
        if sounddevice is None:
            self._status_error("Microphone unavailable", "install sounddevice (portaudio).")
            return

        self._clear_texts()
        self._frames = []
        self._state = RECORDING

        self._set_status("Recording…")
        # Button stays ENABLED so the user can press Stop Recording.
        self._set_button_text("🛑 Stop Recording")

        threading.Thread(
            target=self._record_loop, args=(sounddevice,), daemon=True
        ).start()

    def _record_loop(self, sounddevice) -> None:
        try:
            with sounddevice.InputStream(
                samplerate=self._sample_rate, channels=1, dtype="int16"
            ) as stream:
                while self._state == RECORDING:
                    data, _overflowed = stream.read(1024)
                    self._frames.append(data)
        except Exception as exc:  # noqa: BLE001 - friendly error, never crash
            self._status_error("Microphone unavailable", str(exc))
            self._reset_to_idle()

    def stop_recording(self) -> None:
        self._state = PROCESSING
        self._set_status("Processing…")
        self._set_button_text("🎤 Start Recording")
        # Disable the button while the pipeline runs to avoid double-start.
        self._set_button_state("disabled")

        threading.Thread(target=self._process_recording, daemon=True).start()

    # --------------------------------------------------------- pipeline
    def _process_recording(self) -> None:
        try:
            if not self._frames:
                self._finish("Ready", "No audio captured.")
                return

            if not self._write_wav():
                return

            transcript = self._transcribe()
            if not transcript:
                self._finish("Ready", "[No speech detected]")
                return

            self._append_text(self.you_text, transcript)

            self._set_status("Generating response…")
            reply = self._ask_gemini(transcript)
            self._append_text(self.ai_text, reply)

            self._set_status("Playing response…")
            self._play_audio(reply)
        except Exception as exc:  # noqa: BLE001 - never crash unexpectedly
            self._status_error("Error", str(exc))
        finally:
            self._cleanup_temp_files()
            self._finish("Ready")

    def _write_wav(self) -> bool:
        scipy = _safe_import("scipy.io.wavfile")
        if scipy is None:
            self._status_error("Error", "scipy not installed.")
            return False
        try:
            import numpy as np

            audio = np.concatenate(self._frames, axis=0)
            with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp:
                wav_path = tmp.name
            scipy.write(wav_path, self._sample_rate, audio)
            self._current_wav = wav_path
            return True
        except Exception as exc:  # noqa: BLE001
            self._status_error("Error", f"Could not write audio: {exc}")
            return False

    # -------------------------------------------------------- whisper
    def _get_whisper_model(self):
        """Return the Whisper model, loading it exactly once (thread-safe)."""
        if self._whisper_model is not None:
            return self._whisper_model
        with self._whisper_lock:
            if self._whisper_model is None:
                import whisper

                self._whisper_model = whisper.load_model("base")
        return self._whisper_model

    def _transcribe(self) -> str:
        self._set_status("Processing…")
        try:
            import whisper  # noqa: F401 - presence check
        except Exception:  # noqa: BLE001
            self._status_error("Error", "openai-whisper not installed.")
            return ""
        try:
            model = self._get_whisper_model()
            result = model.transcribe(self._current_wav)
            return (result.get("text") or "").strip()
        except Exception as exc:  # noqa: BLE001
            self._status_error("Error", f"Whisper failed: {exc}")
            return ""

    # -------------------------------------------------------- gemini
    def _ask_gemini(self, prompt: str) -> str:
        if not API_KEY:
            return (
                "Error: API key missing.\n\n"
                "1. Copy .env.example to .env\n"
                "2. Set GEMINI_API_KEY=<your key>\n"
                "3. Restart the app."
            )

        genai = _safe_import("google.genai")
        if genai is None:
            return "Error: install google-genai (see requirements.txt)."

        try:
            client = genai.Client(api_key=API_KEY)
            response = client.models.generate_content(
                model="gemini-2.0-flash", contents=prompt
            )
            return (response.text or "").strip() or "(Empty response)"
        except Exception as exc:  # noqa: BLE001
            return f"Gemini error: {exc}"

    # --------------------------------------------------------- TTS + play
    def _play_audio(self, text: str) -> None:
        try:
            from gtts import gTTS
        except Exception:  # noqa: BLE001
            self._append_text(self.ai_text, "(gTTS not installed — audio skipped)")
            return

        mp3_path = None
        try:
            tts = gTTS(text=text, lang="en")
            with tempfile.NamedTemporaryFile(suffix=".mp3", delete=False) as tmp:
                mp3_path = tmp.name
            tts.save(mp3_path)
        except Exception as exc:  # noqa: BLE001
            self._append_text(self.ai_text, f"TTS failed: {exc}")
            return

        try:
            self._play_mp3(mp3_path)
        finally:
            if mp3_path and os.path.exists(mp3_path):
                try:
                    os.remove(mp3_path)
                except OSError:
                    pass

    def _play_mp3(self, path: str) -> None:
        pygame = _safe_import("pygame")
        if pygame is None:
            self._append_text(self.ai_text, "(pygame not installed — audio skipped)")
            return

        try:
            if self._pygame is None:
                pygame.mixer.init()
                self._pygame = pygame
            pygame.mixer.music.load(path)
            pygame.mixer.music.play()
            while pygame.mixer.music.get_busy():
                pygame.time.wait(50)
        except Exception as exc:  # noqa: BLE001
            self._append_text(self.ai_text, f"Playback failed: {exc}")

    # ------------------------------------------------------------ misc
    def _status_error(self, title: str, detail: str) -> None:
        self._set_status(title)
        self._append_text(self.ai_text, f"{title}: {detail}")

    def _finish(self, status: str, note: str = "") -> None:
        self._set_status(status)
        if note:
            self._append_text(self.ai_text, note)
        self._reset_to_idle()

    def _reset_to_idle(self) -> None:
        self._state = IDLE
        self._set_button_text("🎤 Start Recording")
        self._set_button_state("normal")

    def _cleanup_temp_files(self) -> None:
        for attr in ("_current_wav",):
            path = getattr(self, attr, None)
            if path and os.path.exists(path):
                try:
                    os.remove(path)
                except OSError:
                    pass
        self._frames = []
        # Drop object-refs returned by numpy/sounddevice to free memory.
        if hasattr(self, "_current_wav"):
            del self._current_wav


def main() -> None:
    root = tk.Tk()
    app = VoiceAssistantApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
