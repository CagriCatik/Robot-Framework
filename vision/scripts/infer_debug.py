"""
infer_debug.py — Visualise YOLO detections on any simulator screenshot.

Saves an annotated PNG with bounding boxes, class names, and confidence
scores drawn on each detection, then opens it with the default image viewer.

Usage:
    # Take a screenshot from the live simulator first, then:
    python vision/scripts/infer_debug.py path/to/screenshot.png

    # Use a step screenshot from a recent learning-lab run:
    python vision/scripts/infer_debug.py learning-lab/results/steps/step_003__wait_until_element_is_visible__id_screen_home.png

    # Adjust confidence threshold
    python vision/scripts/infer_debug.py screenshot.png --conf 0.20
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont
from ultralytics import YOLO

PROJECT_ROOT = Path(__file__).resolve().parents[2]
MODEL_PATH   = PROJECT_ROOT / "vision" / "model" / "simulator_icons.pt"

CLASS_NAMES = ["navigation", "media", "climate", "phone",
               "vehicle", "settings", "camera", "weather"]

PALETTE = [
    (58,  95, 168),   # navigation  — steel blue
    (98,  72, 152),   # media       — plum
    (37,  88, 112),   # climate     — teal
    (42, 104,  72),   # phone       — forest
    (122, 48,  48),   # vehicle     — brick
    (74,  80,  96),   # settings    — slate
    (106, 80,  24),   # camera      — amber
    (40,  80, 112),   # weather     — sky
]


def run(image_path: str, conf: float = 0.25, no_open: bool = False):
    if not MODEL_PATH.exists():
        print(f"ERROR: Model not found at {MODEL_PATH}")
        print("Run  python vision/scripts/train.py  first.")
        sys.exit(1)

    import contextlib, io, logging
    logging.getLogger("ultralytics").setLevel(logging.ERROR)
    with contextlib.redirect_stdout(io.StringIO()):
        model = YOLO(str(MODEL_PATH))

    results  = model(image_path, conf=conf, verbose=False)[0]
    img      = Image.open(image_path).convert("RGB")
    draw     = ImageDraw.Draw(img)
    iw, ih   = img.size

    font_sz = max(14, ih // 50)
    try:
        font = ImageFont.truetype("arial.ttf", font_sz)
    except Exception:
        font = ImageFont.load_default()

    detections = []
    if results.boxes:
        for box in results.boxes:
            cls_id   = int(box.cls[0])
            conf_val = float(box.conf[0])
            x1, y1, x2, y2 = [int(v) for v in box.xyxy[0].tolist()]
            name  = CLASS_NAMES[cls_id] if cls_id < len(CLASS_NAMES) else f"cls{cls_id}"
            color = PALETTE[cls_id % len(PALETTE)]
            detections.append((name, conf_val, x1, y1, x2, y2, color))

    if not detections:
        print(f"No detections at confidence >= {conf:.0%}")
    else:
        print(f"\nDetected {len(detections)} icons at conf >= {conf:.0%}:\n")
        print(f"  {'Icon':<12}  {'Conf':>6}   Bbox pixels")
        print(f"  {'-'*12}  {'-'*6}   {'-'*30}")

    for name, conf_val, x1, y1, x2, y2, color in sorted(detections, key=lambda d: d[0]):
        # Draw thick box
        for t in range(3):
            draw.rectangle([x1 - t, y1 - t, x2 + t, y2 + t], outline=color)
        # Label chip
        label      = f"{name}  {conf_val:.0%}"
        text_bbox  = draw.textbbox((0, 0), label, font=font)
        tw, th     = text_bbox[2], text_bbox[3]
        lx, ly     = x1, max(0, y1 - th - 6)
        draw.rectangle([lx, ly, lx + tw + 8, ly + th + 6], fill=color)
        draw.text((lx + 4, ly + 3), label, fill="white", font=font)
        print(f"  {name:<12}  {conf_val:>6.0%}   [{x1},{y1}  {x2},{y2}]")

    # Missing icons
    found   = {d[0] for d in detections}
    missing = [n for n in CLASS_NAMES if n not in found]
    if missing:
        print(f"\n  Not detected: {missing}")
    else:
        print(f"\n  All 8 icons detected.")

    # Save annotated image
    out_path = Path(image_path).with_stem(Path(image_path).stem + "_debug")
    img.save(str(out_path))
    print(f"\nAnnotated image saved: {out_path}")

    # Open with default viewer
    if not no_open:
        if sys.platform == "win32":
            os.startfile(str(out_path))
        elif sys.platform == "darwin":
            subprocess.run(["open", str(out_path)])
        else:
            subprocess.run(["xdg-open", str(out_path)])


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Draw YOLO bounding boxes with labels and confidence on a simulator screenshot"
    )
    parser.add_argument("image", help="Path to the input screenshot (PNG/JPG)")
    parser.add_argument("--conf",    type=float, default=0.25, help="Confidence threshold (default 0.25)")
    parser.add_argument("--no-open", action="store_true",      help="Do not open the image viewer")
    args = parser.parse_args()
    run(args.image, conf=args.conf, no_open=args.no_open)
