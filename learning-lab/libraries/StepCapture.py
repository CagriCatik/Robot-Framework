"""
StepCapture — Robot Framework library + listener.

After every browser-modifying keyword that passes it:
  1. Saves a named step PNG:  step_001__click_button__app_icon_climate.png
  2. Pauses for `pause_seconds`, capturing video frames at `video_fps` during
     that pause — all in the main thread, no background thread.
  3. At end_test, calls FFmpeg to stitch the frames into a proper MP4
     using libx264 / yuv420p — universally playable in any media player.

FFmpeg is used for encoding because OpenCV's bundled FFmpeg codec
('mp4v') consistently fails to write frames on many Windows setups.
The system FFmpeg at ffmpeg_path encodes reliably with full H.264.
"""

import os
import re
import subprocess
import time

from robot.libraries.BuiltIn import BuiltIn


# Browser-modifying keywords that trigger a screenshot + pause
_CAPTURE_AFTER = frozenset({
    "click button",
    "click element",
    "click link",
    "click image",
    "double click element",
    "input text",
    "input password",
    "clear element text",
    "select from list by value",
    "select from list by label",
    "select from list by index",
    "select checkbox",
    "unselect checkbox",
    "go to",
    "reload page",
    "open browser",
    "maximize browser window",
    "set window size",
    "wait until element is visible",
    "wait until element contains",
    "wait until element does not contain",
    "wait until page contains",
    "wait until page contains element",
    "wait until page does not contain element",
    "scroll element into view",
    "press keys",
})

_OPEN_KW  = frozenset({"open browser", "create webdriver"})
_CLOSE_KW = frozenset({"close browser", "close all browsers"})


class StepCapture:
    """Saves step screenshots, paces tests, and records MP4 videos via FFmpeg."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self, pause_seconds=1.0, video_fps=10,
                 ffmpeg_path="C:/ffmpeg/bin/ffmpeg.exe"):
        """
        Args:
            pause_seconds: Pause after each browser action.  During this pause
                           video frames are captured at video_fps.  0 = disabled.
            video_fps:     Target frames per second for the output MP4.
                           10 fps × 1 s pause ≈ 10 frames per action.
            ffmpeg_path:   Full path to the ffmpeg executable.
                           Falls back to 'ffmpeg' (system PATH) if the given
                           path does not exist.
        """
        self.ROBOT_LIBRARY_LISTENER = self

        self._pause       = max(0.0, float(pause_seconds))
        self._video_fps   = max(1, int(video_fps))
        self._ffmpeg      = self._resolve_ffmpeg(ffmpeg_path)

        # Step screenshot state
        self._step        = 0
        self._steps_dir   = None

        # Video state
        self._video_frames: list = []   # list of raw PNG bytes
        self._videos_dir  = None
        self._suite_name  = ""
        self._test_name   = ""

        # SeleniumLibrary reference — cached in main thread when browser opens
        self._sl          = None

    # ─────────────────────────────────────────────────────────────────
    # Listener hooks
    # ─────────────────────────────────────────────────────────────────

    def start_suite(self, name, attrs):
        self._suite_name = name
        self._videos_dir = None

    def start_test(self, name, attrs):
        self._step         = 0
        self._test_name    = name
        self._video_frames = []

    def end_keyword(self, name, attrs):
        if attrs.get("status") != "PASS":
            return

        kw = name.lower().split(".")[-1].strip()

        if kw in _OPEN_KW:
            try:
                self._sl = BuiltIn().get_library_instance("SeleniumLibrary")
            except Exception:
                self._sl = None
        elif kw in _CLOSE_KW:
            self._sl = None

        if kw in _CAPTURE_AFTER:
            self._take_step_screenshot(kw, attrs.get("args", []))
            if self._pause > 0 and self._sl:
                self._capture_frames_during_pause()

    def end_test(self, name, attrs):
        if self._video_frames and self._ffmpeg:
            self._write_video()
        self._video_frames = []

    # ─────────────────────────────────────────────────────────────────
    # Public keywords
    # ─────────────────────────────────────────────────────────────────

    def capture_step_screenshot(self, description):
        """Saves a manually-triggered step screenshot at any checkpoint.

        File is named  step_NNN__checkpoint__<description>.png

        Example:
        |    Capture Step Screenshot    climate_defaults_verified
        """
        self._take_step_screenshot("checkpoint", [description])

    def set_step_pause(self, seconds):
        """Changes the between-step pause at runtime.

        Example:
        |    Set Step Pause    2.0    # slow-motion demo
        |    Set Step Pause    0      # full speed / CI mode
        """
        self._pause = max(0.0, float(seconds))

    # ─────────────────────────────────────────────────────────────────
    # Step screenshot
    # ─────────────────────────────────────────────────────────────────

    def _take_step_screenshot(self, keyword_name, args):
        try:
            driver = getattr(self._sl, "driver", None) if self._sl else None
            if not driver:
                return

            self._step  += 1
            steps_dir    = self._resolve_steps_dir()
            first_arg    = str(args[0]) if args else ""
            arg_clean    = re.sub(r"[^a-z0-9]", "_", first_arg.lower())
            arg_clean    = re.sub(r"_+", "_", arg_clean).strip("_")[:45]
            kw_clean     = keyword_name.replace(" ", "_")
            filename     = f"step_{self._step:03d}__{kw_clean}__{arg_clean}.png"
            filepath     = os.path.join(steps_dir, filename)

            driver.save_screenshot(filepath)

            out_dir = self._resolve_output_dir()
            rel     = os.path.relpath(filepath, out_dir).replace(os.sep, "/")
            BuiltIn().log(
                f"<b>Step {self._step}</b>: {keyword_name}({first_arg})<br>"
                f'<img src="{rel}" '
                f'style="max-width:900px;border:1px solid #333;margin:6px 0">',
                level="INFO",
                html=True,
            )
        except Exception:
            pass

    # ─────────────────────────────────────────────────────────────────
    # Video frame capture  (synchronous, in main thread)
    # ─────────────────────────────────────────────────────────────────

    def _capture_frames_during_pause(self):
        """Fills video frames while pausing — everything in the main thread."""
        driver = getattr(self._sl, "driver", None) if self._sl else None
        if not driver:
            time.sleep(self._pause)
            return

        interval  = 1.0 / self._video_fps
        deadline  = time.monotonic() + self._pause
        next_slot = time.monotonic() + interval

        while True:
            try:
                png = driver.get_screenshot_as_png()
                self._video_frames.append(png)
            except Exception:
                pass

            sleep_until = min(next_slot, deadline)
            wait = sleep_until - time.monotonic()
            if wait > 0:
                time.sleep(wait)
            next_slot += interval
            if time.monotonic() >= deadline:
                break

    # ─────────────────────────────────────────────────────────────────
    # Video writing  via FFmpeg
    # ─────────────────────────────────────────────────────────────────

    def _write_video(self):
        """Encodes accumulated PNG frames into an MP4 via image2pipe + FFmpeg.

        Frames are piped directly to ffmpeg's stdin — no temp files, no numbered
        sequences, no Windows path quirks.  CREATE_NO_WINDOW prevents ffmpeg from
        writing progress text to the console and corrupting Robot's output.xml.
        """
        try:
            # Filter out any empty / corrupt captures
            frames = [f for f in self._video_frames if f and len(f) > 512]
            if not frames:
                return

            output_dir  = self._resolve_videos_dir()
            filename    = self._build_video_filename()
            output_path = os.path.join(output_dir, filename)

            # FFmpeg command — image2pipe reads PNG frames from stdin
            # -f image2pipe   : tell ffmpeg the input is a stream of images
            # -vcodec png     : each image is a PNG
            # -framerate      : playback speed of the output video
            # -i pipe:0       : read from stdin
            # -vf scale       : ensure width & height are multiples of 2 (H.264 req.)
            # -c:v libx264    : H.264 — plays everywhere
            # -pix_fmt yuv420p: broad compatibility (QuickTime, VLC, browsers)
            # -preset fast    : reasonable encode speed
            # -movflags +faststart : put moov atom at start for streaming
            cmd = [
                self._ffmpeg,
                "-y",
                "-f", "image2pipe",
                "-vcodec", "png",
                "-framerate", str(self._video_fps),
                "-i", "pipe:0",
                "-vf", "scale=trunc(iw/2)*2:trunc(ih/2)*2",
                "-c:v", "libx264",
                "-pix_fmt", "yuv420p",
                "-preset", "fast",
                "-movflags", "+faststart",
                output_path,
            ]

            # CREATE_NO_WINDOW: prevent ffmpeg from writing to the Windows console
            # which would corrupt Robot Framework's stdout / output.xml.
            creation_flags = 0
            if os.name == "nt":
                creation_flags = subprocess.CREATE_NO_WINDOW

            # DEVNULL for both stdout and stderr prevents ffmpeg from writing
            # to any inherited file descriptor (which would corrupt output.xml).
            proc = subprocess.Popen(
                cmd,
                stdin=subprocess.PIPE,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                creationflags=creation_flags,
            )
            for png_bytes in frames:
                proc.stdin.write(png_bytes)
            proc.stdin.close()
            proc.wait()

            if proc.returncode != 0:
                # Re-run with stderr captured so we can log the reason
                err_proc = subprocess.run(
                    cmd,
                    input=b"",          # empty stdin — we just want the error text
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.PIPE,
                    creationflags=creation_flags,
                )
                err_msg = err_proc.stderr.decode("utf-8", errors="replace")[-600:]
                BuiltIn().log(
                    f"StepCapture: ffmpeg exited {proc.returncode}.\n{err_msg}",
                    level="WARN",
                )
                return

            n   = len(frames)
            dur = round(n / self._video_fps, 1)
            kb  = round(os.path.getsize(output_path) / 1024)
            rel = os.path.relpath(output_path, self._resolve_output_dir()).replace(os.sep, "/")

            BuiltIn().log(
                f"<b>Video</b>: "
                f"<a href='{rel}' target='_blank'>{filename}</a>"
                f" ·{n} frames @ {self._video_fps} fps"
                f" ·{dur} s ·{kb} KB",
                level="INFO",
                html=True,
            )

        except Exception as exc:
            try:
                BuiltIn().log(f"StepCapture: video write failed — {exc}", level="WARN")
            except Exception:
                pass

    # ─────────────────────────────────────────────────────────────────
    # Path / config helpers
    # ─────────────────────────────────────────────────────────────────

    @staticmethod
    def _resolve_ffmpeg(path: str) -> str:
        """Returns the ffmpeg path to use, falling back to PATH if the given
        path does not exist."""
        if os.path.isfile(path):
            return path
        # Try the bin directory the user specified
        candidate = os.path.join(os.path.dirname(path), "ffmpeg.exe")
        if os.path.isfile(candidate):
            return candidate
        # Fall back to whatever is on PATH
        return "ffmpeg"

    def _build_video_filename(self) -> str:
        def clean(s):
            s = re.sub(r"[^a-z0-9]", "_", s.lower())
            return re.sub(r"_+", "_", s).strip("_")[:50]
        suite = clean(self._suite_name) if self._suite_name else "suite"
        test  = clean(self._test_name)  if self._test_name  else "test"
        return f"{suite}__{test}.mp4"

    def _resolve_output_dir(self) -> str:
        try:
            return BuiltIn().get_variable_value("${OUTPUT DIR}") or "."
        except Exception:
            return "."

    def _resolve_steps_dir(self) -> str:
        if not self._steps_dir:
            out = self._resolve_output_dir()
            self._steps_dir = os.path.join(out, "steps")
            os.makedirs(self._steps_dir, exist_ok=True)
        return self._steps_dir

    def _resolve_videos_dir(self) -> str:
        if not self._videos_dir:
            out = self._resolve_output_dir()
            self._videos_dir = os.path.join(out, "videos")
            os.makedirs(self._videos_dir, exist_ok=True)
        return self._videos_dir
