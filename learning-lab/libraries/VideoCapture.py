"""
VideoCapture — Robot Framework library + listener for simulator test recording.

When imported as a Library it self-registers as a listener.  Every test that
opens a real browser gets its own MP4 file written to:

    <OUTPUT_DIR>/videos/<suite_name>__<test_name>.mp4

Key design choice:
  The SeleniumLibrary reference is captured in the *main* Robot Framework thread
  (inside the end_keyword hook) and stored as self._sl.  The background capture
  thread uses self._sl.driver directly — no BuiltIn() calls from a background
  thread, which is not safe in RF's execution context.

Constraints enforced automatically:
  • Only records when sl.driver is live — API / no-browser tests are silently skipped.
  • One MP4 file per test, regardless of whether the browser is shared (suite setup).
  • Thread is joined cleanly on test end before the next test begins.
"""

import io
import os
import re
import threading
import time

import cv2
import numpy as np
from PIL import Image

from robot.libraries.BuiltIn import BuiltIn


_OPEN_KW  = frozenset({"open browser", "create webdriver"})
_CLOSE_KW = frozenset({"close browser", "close all browsers"})


class VideoCapture:
    """Records each browser-based simulator test as an MP4."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"
    ROBOT_LISTENER_API_VERSION = 2

    def __init__(self, fps: int = 10, output_subdir: str = "videos"):
        """
        Args:
            fps:           Capture rate.  10 fps is smooth for ~30-second tests.
                           Use 5 for very long suites to keep file sizes small.
            output_subdir: Sub-folder inside ${OUTPUT DIR} for the video files.
        """
        self.ROBOT_LIBRARY_LISTENER = self

        self._fps           = max(1, int(fps))
        self._output_subdir = output_subdir

        self._suite_name    = ""
        self._test_name     = ""
        self._frames: list  = []
        self._lock          = threading.Lock()
        self._stop_event    = threading.Event()
        self._thread: threading.Thread | None = None

        # SeleniumLibrary reference cached in the MAIN thread — safe to share
        self._sl            = None
        self._output_dir    = None   # resolved lazily on first write

    # ──────────────────────────────────────────────────────────────────
    # Listener hooks  (all run on the Robot Framework main thread)
    # ──────────────────────────────────────────────────────────────────

    def start_suite(self, name, attrs):
        self._suite_name = name
        self._output_dir = None   # resolve fresh per suite

    def start_test(self, name, attrs):
        """Stop any leftover thread from the previous test, reset frame buffer."""
        self._stop_thread()
        self._test_name = name
        with self._lock:
            self._frames = []
        # If a shared browser is already open (suite-level setup), start now
        if self._sl and getattr(self._sl, "driver", None):
            self._start_thread()

    def end_keyword(self, name, attrs):
        kw = name.lower().split(".")[-1].strip()

        if kw in _OPEN_KW and attrs.get("status") == "PASS":
            # Cache the SeleniumLibrary reference here — main thread, always safe
            try:
                self._sl = BuiltIn().get_library_instance("SeleniumLibrary")
            except Exception:
                self._sl = None
            if not (self._thread and self._thread.is_alive()):
                self._start_thread()

        elif kw in _CLOSE_KW:
            self._stop_thread()
            self._flush()
            # Browser is gone — clear the cached reference
            self._sl = None

    def end_test(self, name, attrs):
        """Always stop recording and save at the end of each test."""
        self._stop_thread()
        self._flush()

    # ──────────────────────────────────────────────────────────────────
    # Thread management
    # ──────────────────────────────────────────────────────────────────

    def _start_thread(self):
        self._stop_event.clear()
        self._thread = threading.Thread(
            target=self._capture_loop,
            name="VideoCapture",
            daemon=True,
        )
        self._thread.start()

    def _stop_thread(self):
        self._stop_event.set()
        if self._thread and self._thread.is_alive():
            self._thread.join(timeout=max(3.0, 3.0 / self._fps))
        self._thread = None

    def _capture_loop(self):
        """Runs in the background thread.  Uses self._sl cached by the main thread."""
        interval = 1.0 / self._fps
        while not self._stop_event.is_set():
            try:
                driver = getattr(self._sl, "driver", None) if self._sl else None
                if driver:
                    png = driver.get_screenshot_as_png()
                    with self._lock:
                        self._frames.append(png)
            except Exception:
                pass
            self._stop_event.wait(timeout=interval)

    # ──────────────────────────────────────────────────────────────────
    # Video writing  (runs on main thread after stop_thread)
    # ──────────────────────────────────────────────────────────────────

    def _flush(self):
        with self._lock:
            frames = list(self._frames)
            self._frames = []
        if not frames:
            return
        try:
            self._write_mp4(frames)
        except Exception as exc:
            try:
                BuiltIn().log(f"VideoCapture: could not write MP4 — {exc}", level="WARN")
            except Exception:
                pass

    def _write_mp4(self, frames: list):
        videos_dir = self._resolve_videos_dir()
        filename   = self._build_filename()
        filepath   = os.path.join(videos_dir, filename)

        # Frame dimensions from the first captured frame
        first = Image.open(io.BytesIO(frames[0])).convert("RGB")
        w, h  = first.size

        fourcc = cv2.VideoWriter_fourcc(*"mp4v")
        writer = cv2.VideoWriter(filepath, fourcc, float(self._fps), (w, h))

        for png_bytes in frames:
            img   = Image.open(io.BytesIO(png_bytes)).convert("RGB")
            frame = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
            writer.write(frame)

        writer.release()

        dur_s  = round(len(frames) / self._fps, 1)
        size_kb = round(os.path.getsize(filepath) / 1024)
        rel    = os.path.relpath(filepath, self._resolve_output_dir()).replace(os.sep, "/")

        BuiltIn().log(
            f"<b>Video recorded</b>: "
            f"<a href='{rel}' target='_blank'>{filename}</a> "
            f"&nbsp;·&nbsp; {len(frames)} frames @ {self._fps} fps "
            f"&nbsp;·&nbsp; {dur_s}s &nbsp;·&nbsp; {size_kb} KB",
            level="INFO",
            html=True,
        )

    # ──────────────────────────────────────────────────────────────────
    # Path helpers
    # ──────────────────────────────────────────────────────────────────

    def _build_filename(self) -> str:
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

    def _resolve_videos_dir(self) -> str:
        if not self._output_dir:
            base = self._resolve_output_dir()
            self._output_dir = os.path.join(base, self._output_subdir)
            os.makedirs(self._output_dir, exist_ok=True)
        return self._output_dir

    # ──────────────────────────────────────────────────────────────────
    # Public keyword
    # ──────────────────────────────────────────────────────────────────

    def set_video_fps(self, fps):
        """Changes the capture frame rate at runtime (call before opening browser).

        Example:
        |    Set Video Fps    5     # slower capture, smaller files
        |    Set Video Fps    15    # smoother playback
        """
        self._fps = max(1, int(fps))
