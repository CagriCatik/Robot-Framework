"""
SimulatorVision — Robot Framework keyword library for YOLO11-based
object detection on the automotive center display simulator.

Import in a test suite:
    Library    ${EXECDIR}/vision/libraries/SimulatorVision.py
    ...        model_path=${EXECDIR}/vision/model/simulator_icons.pt

All keywords that accept a `screenshot_path` expect an absolute or
relative path to a PNG/JPG screenshot captured by SeleniumLibrary's
`Capture Page Screenshot`.
"""

import os
from pathlib import Path
from typing import List, Dict, Any

# ── Class metadata (mirrors dataset.yaml) ────────────────────────────────────
CLASS_NAMES = ["navigation", "media", "climate", "phone",
               "vehicle",   "settings", "camera",  "weather"]

# Icons expected to appear in row 0 (top) and row 1 (bottom) of the 4×2 grid
TOP_ROW_ICONS    = ["navigation", "media", "climate", "phone"]
BOTTOM_ROW_ICONS = ["vehicle", "settings", "camera", "weather"]


class SimulatorVision:
    """YOLO11-based detection keywords for the simulator app-icon grid."""

    def __init__(self,
                 model_path: str | None = None,
                 conf_threshold: float = 0.30):
        """
        Args:
            model_path:      Path to the trained .pt weights file.
                             Defaults to  vision/model/simulator_icons.pt
                             relative to ${EXECDIR}.
            conf_threshold:  Minimum confidence to consider a detection valid.
        """
        self._conf         = float(conf_threshold)
        self._model        = None
        self._model_path   = model_path
        self._last_results: List[Dict[str, Any]] = []

    # ── Model management ─────────────────────────────────────────────────────

    def load_vision_model(self, model_path: str | None = None):
        """Explicitly loads (or reloads) the YOLO model.

        Robot Framework calls this automatically on the first detection keyword,
        but calling it in Suite Setup is more predictable.

        Example:
        |    Suite Setup    Load Vision Model
        |    Suite Setup    Load Vision Model    vision/model/simulator_icons.pt
        """
        if model_path:
            self._model_path = model_path
        self._model = self._build_model()

    def _build_model(self):
        import contextlib, io, logging
        from ultralytics import YOLO

        path = self._resolve_model_path()
        if not os.path.isfile(path):
            raise FileNotFoundError(
                f"YOLO model not found at '{path}'.\n"
                "Run the training pipeline first:\n"
                "  python vision/scripts/capture_training_data.py\n"
                "  python vision/scripts/train.py"
            )

        # Suppress YOLO's stdout chatter during model loading — it writes directly
        # to fd 1 and would corrupt Robot Framework's output.xml.
        logging.getLogger("ultralytics").setLevel(logging.ERROR)
        with contextlib.redirect_stdout(io.StringIO()):
            model = YOLO(path)
        return model

    def _ensure_model(self):
        if self._model is None:
            self._model = self._build_model()

    def _resolve_model_path(self) -> str:
        if self._model_path:
            return str(self._model_path)
        # Default: <EXECDIR>/vision/model/simulator_icons.pt
        try:
            from robot.libraries.BuiltIn import BuiltIn
            execdir = BuiltIn().get_variable_value("${EXECDIR}") or ""
        except Exception:
            execdir = ""
        return str(Path(execdir) / "vision" / "model" / "simulator_icons.pt")

    # ── Core detection ────────────────────────────────────────────────────────

    def detect_icons_in_screenshot(self, screenshot_path: str,
                                   conf: float | None = None) -> List[Dict]:
        """Runs YOLO inference on the screenshot and returns all detections.

        Each detection is a dict:
            {
              'name':       'navigation',
              'class_id':   0,
              'confidence': 0.87,
              'x1': 120, 'y1': 250, 'x2': 220, 'y2': 380,   # pixels
              'cx': 0.12, 'cy': 0.35,                         # normalised centre
              'row': 0                                         # 0 = top, 1 = bottom
            }

        The list is also stored as ${LAST_DETECTIONS} for inspection.

        Example:
        |    ${detections}=    Detect Icons In Screenshot    ${SCREENSHOT}
        |    Log    Found ${detections.__len__()} icons
        """
        self._ensure_model()
        threshold = float(conf) if conf is not None else self._conf

        results = self._model(screenshot_path, conf=threshold, verbose=False)[0]
        detections = []

        if results.boxes:
            img_w = results.orig_shape[1]
            img_h = results.orig_shape[0]

            for box in results.boxes:
                cls_id   = int(box.cls[0])
                conf_val = float(box.conf[0])
                x1, y1, x2, y2 = [float(v) for v in box.xyxy[0].tolist()]
                cx = ((x1 + x2) / 2) / img_w
                cy = ((y1 + y2) / 2) / img_h
                name = CLASS_NAMES[cls_id] if cls_id < len(CLASS_NAMES) else f"class_{cls_id}"
                detections.append({
                    "name":       name,
                    "class_id":   cls_id,
                    "confidence": round(conf_val, 4),
                    "x1": int(x1), "y1": int(y1),
                    "x2": int(x2), "y2": int(y2),
                    "cx": round(cx, 4),
                    "cy": round(cy, 4),
                    "row": 0 if name in TOP_ROW_ICONS else 1,
                })

        self._last_results = detections
        return detections

    # ── Assertion keywords ────────────────────────────────────────────────────

    def app_icon_should_be_detected(self, screenshot_path: str,
                                    icon_name: str,
                                    min_conf: float = 0.30):
        """Fails if the given icon is not detected with at least min_conf confidence.

        Example:
        |    App Icon Should Be Detected    ${SCREENSHOT}    navigation
        |    App Icon Should Be Detected    ${SCREENSHOT}    climate    min_conf=0.5
        """
        detections = self.detect_icons_in_screenshot(screenshot_path)
        icon_name  = icon_name.lower().strip()
        matches    = [d for d in detections if d["name"] == icon_name
                      and d["confidence"] >= float(min_conf)]
        if not matches:
            detected_names = [d["name"] for d in detections]
            raise AssertionError(
                f"Icon '{icon_name}' not detected at confidence >= {min_conf:.0%}.\n"
                f"Detected icons: {detected_names or '(none)'}"
            )
        best = max(matches, key=lambda d: d["confidence"])
        return best

    def app_icon_should_not_be_detected(self, screenshot_path: str,
                                        icon_name: str,
                                        min_conf: float = 0.30):
        """Fails if the given icon IS detected.  Useful for negative tests.

        Example:
        |    Navigate Away From Home Screen
        |    App Icon Should Not Be Detected    ${SCREENSHOT}    navigation
        """
        detections = self.detect_icons_in_screenshot(screenshot_path)
        icon_name  = icon_name.lower().strip()
        matches    = [d for d in detections if d["name"] == icon_name
                      and d["confidence"] >= float(min_conf)]
        if matches:
            raise AssertionError(
                f"Icon '{icon_name}' was unexpectedly detected "
                f"(confidence {matches[0]['confidence']:.0%})."
            )

    def all_app_icons_should_be_detected(self, screenshot_path: str,
                                         min_conf: float = 0.30):
        """Fails if any of the 8 expected icons is missing from the screenshot.

        Example:
        |    All App Icons Should Be Detected    ${SCREENSHOT}
        |    All App Icons Should Be Detected    ${SCREENSHOT}    min_conf=0.50
        """
        detections  = self.detect_icons_in_screenshot(screenshot_path)
        found_names = {d["name"] for d in detections
                       if d["confidence"] >= float(min_conf)}
        missing     = [n for n in CLASS_NAMES if n not in found_names]
        if missing:
            raise AssertionError(
                f"Missing icon(s) at confidence >= {min_conf:.0%}: "
                f"{missing}\nDetected: {sorted(found_names)}"
            )

    def icons_in_top_row_should_be_detected(self, screenshot_path: str,
                                            min_conf: float = 0.30):
        """Asserts navigation, media, climate, and phone are all detected.

        Example:
        |    Icons In Top Row Should Be Detected    ${SCREENSHOT}
        """
        detections  = self.detect_icons_in_screenshot(screenshot_path)
        found_names = {d["name"] for d in detections
                       if d["confidence"] >= float(min_conf)}
        missing     = [n for n in TOP_ROW_ICONS if n not in found_names]
        if missing:
            raise AssertionError(
                f"Top-row icon(s) missing at >= {min_conf:.0%}: {missing}\n"
                f"Detected: {sorted(found_names)}"
            )

    def icons_in_bottom_row_should_be_detected(self, screenshot_path: str,
                                               min_conf: float = 0.30):
        """Asserts vehicle, settings, camera, and weather are all detected.

        Example:
        |    Icons In Bottom Row Should Be Detected    ${SCREENSHOT}
        """
        detections  = self.detect_icons_in_screenshot(screenshot_path)
        found_names = {d["name"] for d in detections
                       if d["confidence"] >= float(min_conf)}
        missing     = [n for n in BOTTOM_ROW_ICONS if n not in found_names]
        if missing:
            raise AssertionError(
                f"Bottom-row icon(s) missing at >= {min_conf:.0%}: {missing}\n"
                f"Detected: {sorted(found_names)}"
            )

    def detection_count_should_be(self, screenshot_path: str,
                                   expected_count: int,
                                   min_conf: float = 0.30):
        """Asserts the number of detected icons equals expected_count.

        Example:
        |    Detection Count Should Be    ${SCREENSHOT}    8
        """
        detections = self.detect_icons_in_screenshot(screenshot_path)
        found      = [d for d in detections if d["confidence"] >= float(min_conf)]
        if len(found) != int(expected_count):
            raise AssertionError(
                f"Expected {expected_count} detections at >= {min_conf:.0%}, "
                f"got {len(found)}.\n"
                f"Detected: {[d['name'] for d in found]}"
            )

    def icon_confidence_should_be_above(self, screenshot_path: str,
                                        icon_name: str,
                                        threshold: float):
        """Asserts a specific icon's best detection confidence exceeds threshold.

        Example:
        |    Icon Confidence Should Be Above    ${SCREENSHOT}    navigation    0.70
        """
        detections = self.detect_icons_in_screenshot(screenshot_path)
        icon_name  = icon_name.lower().strip()
        matches    = [d for d in detections if d["name"] == icon_name]
        if not matches:
            raise AssertionError(f"Icon '{icon_name}' not detected at all.")
        best_conf = max(d["confidence"] for d in matches)
        if best_conf < float(threshold):
            raise AssertionError(
                f"Icon '{icon_name}' best confidence {best_conf:.0%} "
                f"is below threshold {float(threshold):.0%}."
            )
        return best_conf

    # ── Utility keywords ──────────────────────────────────────────────────────

    def get_icon_bounding_box(self, screenshot_path: str,
                               icon_name: str) -> Dict:
        """Returns the bounding box dict for the highest-confidence detection.

        Returns: {'x1': int, 'y1': int, 'x2': int, 'y2': int,
                  'cx': float, 'cy': float, 'confidence': float}

        Example:
        |    ${box}=    Get Icon Bounding Box    ${SCREENSHOT}    climate
        |    Log    Climate icon at x=${box}[x1] y=${box}[y1]
        """
        detections = self.detect_icons_in_screenshot(screenshot_path)
        icon_name  = icon_name.lower().strip()
        matches    = [d for d in detections if d["name"] == icon_name]
        if not matches:
            raise AssertionError(f"Icon '{icon_name}' not detected.")
        return max(matches, key=lambda d: d["confidence"])

    def get_detection_summary(self, screenshot_path: str,
                               min_conf: float = 0.30) -> Dict:
        """Returns a summary dict with counts and names.

        Example:
        |    ${summary}=    Get Detection Summary    ${SCREENSHOT}
        |    Log    Detected ${summary}[count] icons: ${summary}[names]
        """
        detections = self.detect_icons_in_screenshot(screenshot_path)
        filtered   = [d for d in detections if d["confidence"] >= float(min_conf)]
        return {
            "count":   len(filtered),
            "names":   sorted(d["name"] for d in filtered),
            "missing": sorted(n for n in CLASS_NAMES
                              if n not in {d["name"] for d in filtered}),
        }

    def detect_and_show_debug_image(self, screenshot_path: str,
                                     output_path: str | None = None,
                                     min_conf: float = 0.25):
        """Runs detection, draws labelled bounding boxes with confidence scores,
        saves the result, and embeds it inline in log.html.

        Each box is labelled as  <name> <conf%>  so you can see at a glance
        which icons were found and how confident the model was.

        Example:
        |    ${shot}=    Capture Screenshot    home_debug
        |    Detect And Show Debug Image    ${shot}
        |    Detect And Show Debug Image    ${shot}    vision/results/debug.png
        """
        import cv2
        from PIL import Image, ImageDraw, ImageFont

        self._ensure_model()
        threshold  = float(min_conf)
        detections = self.detect_icons_in_screenshot(screenshot_path, conf=threshold)

        img = Image.open(screenshot_path).convert("RGB")
        draw = ImageDraw.Draw(img)

        # Colour palette — one per class index
        PALETTE = [
            "#3a5fa8", "#624898", "#255870", "#2a6848",
            "#7a3030", "#4a5060", "#6a5018", "#285070",
        ]

        for det in detections:
            color = PALETTE[det["class_id"] % len(PALETTE)]
            x1, y1, x2, y2 = det["x1"], det["y1"], det["x2"], det["y2"]
            # Box
            for t in range(3):
                draw.rectangle([x1 - t, y1 - t, x2 + t, y2 + t], outline=color)
            # Label background
            label   = f"{det['name']}  {det['confidence']:.0%}"
            font_sz = max(12, (y2 - y1) // 5)
            try:
                font = ImageFont.truetype("arial.ttf", font_sz)
            except Exception:
                font = ImageFont.load_default()
            bbox_text = draw.textbbox((x1, y1 - font_sz - 4), label, font=font)
            draw.rectangle(bbox_text, fill=color)
            draw.text((x1, y1 - font_sz - 4), label, fill="white", font=font)

        # Determine output path
        if not output_path:
            stem    = os.path.splitext(screenshot_path)[0]
            output_path = stem + "_debug.png"

        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        img.save(output_path)

        # Log summary table + embedded image in log.html
        rows = "".join(
            f"<tr><td>{d['name']}</td><td>{d['confidence']:.0%}</td>"
            f"<td>[{d['x1']},{d['y1']} → {d['x2']},{d['y2']}]</td></tr>"
            for d in sorted(detections, key=lambda d: d["class_id"])
        )
        missing = [n for n in CLASS_NAMES
                   if n not in {d["name"] for d in detections}]
        missing_html = (
            f'<p style="color:#c05050"><b>Not detected:</b> {", ".join(missing)}</p>'
            if missing else '<p style="color:#3d8050"><b>All 8 icons detected</b></p>'
        )

        try:
            from robot.libraries.BuiltIn import BuiltIn
            out_dir = BuiltIn().get_variable_value("${OUTPUT DIR}") or "."
            rel     = os.path.relpath(output_path, out_dir).replace(os.sep, "/")
            BuiltIn().log(
                f"<b>Detection Debug Image</b> — {len(detections)}/8 icons "
                f"at conf >= {threshold:.0%}<br>"
                f'<img src="{rel}" style="max-width:100%;border:1px solid #444;margin:8px 0"><br>'
                f"<table border='1' cellpadding='4' style='border-collapse:collapse;font-size:13px'>"
                f"<tr><th>Icon</th><th>Confidence</th><th>Bounding Box (pixels)</th></tr>"
                f"{rows}</table>{missing_html}",
                level="INFO", html=True,
            )
        except Exception:
            pass

        return output_path

    def save_annotated_screenshot(self, screenshot_path: str,
                                   output_path: str,
                                   min_conf: float = 0.25):
        """Saves a copy of the screenshot with YOLO bounding-box overlays drawn.

        Example:
        |    Save Annotated Screenshot    ${SCREENSHOT}    ${OUTPUTDIR}/annotated.png
        """
        self._ensure_model()
        results = self._model(screenshot_path, conf=float(min_conf), verbose=False)[0]
        annotated_bgr = results.plot()
        import cv2
        os.makedirs(os.path.dirname(os.path.abspath(output_path)), exist_ok=True)
        cv2.imwrite(output_path, annotated_bgr)

        try:
            from robot.libraries.BuiltIn import BuiltIn
            out_dir = BuiltIn().get_variable_value("${OUTPUT DIR}") or "."
            rel     = os.path.relpath(output_path, out_dir).replace(os.sep, "/")
            BuiltIn().log(
                f"<b>Annotated detection</b>:<br>"
                f'<img src="{rel}" style="max-width:900px;border:1px solid #555">',
                level="INFO", html=True,
            )
        except Exception:
            pass

        return output_path
