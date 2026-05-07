"""
infer.py — Quick inference sanity-check on any image.

Usage:
    # Detect on a simulator screenshot saved by Robot Framework
    python vision/scripts/infer.py learning-lab/results/steps/step_001__open_browser__url.png

    # Detect on a custom image
    python vision/scripts/infer.py path/to/image.png

    # Detect and save annotated image
    python vision/scripts/infer.py path/to/image.png --save
"""

import argparse
import sys
from pathlib import Path

from ultralytics import YOLO

PROJECT_ROOT = Path(__file__).resolve().parents[2]
MODEL_PATH   = PROJECT_ROOT / "vision" / "model" / "simulator_icons.pt"

CLASS_NAMES = ["navigation", "media", "climate", "phone",
               "vehicle", "settings", "camera", "weather"]


def run(image_path: str, save: bool = False, conf: float = 0.25):
    if not MODEL_PATH.exists():
        print(f"ERROR: Model not found at {MODEL_PATH}")
        print("Run  python vision/scripts/train.py  first.")
        sys.exit(1)

    model = YOLO(str(MODEL_PATH))
    results = model(image_path, conf=conf)[0]

    boxes = results.boxes
    if boxes is None or len(boxes) == 0:
        print("No objects detected.")
    else:
        print(f"Detected {len(boxes)} object(s):\n")
        print(f"  {'Icon':<12}  {'Conf':>6}   Bounding box (x1 y1 x2 y2 pixels)")
        print(f"  {'-'*12}  {'-'*6}   {'-'*40}")
        for box in boxes:
            cls  = int(box.cls[0])
            conf_val = float(box.conf[0])
            x1, y1, x2, y2 = [int(v) for v in box.xyxy[0].tolist()]
            name = CLASS_NAMES[cls] if cls < len(CLASS_NAMES) else f"class_{cls}"
            print(f"  {name:<12}  {conf_val:>6.2%}   [{x1:4d} {y1:4d} {x2:4d} {y2:4d}]")

    if save:
        out_path = Path(image_path).with_stem(Path(image_path).stem + "_annotated")
        annotated = results.plot()
        import cv2
        cv2.imwrite(str(out_path), annotated)
        print(f"\nAnnotated image saved to: {out_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run YOLO11n simulator icon detection")
    parser.add_argument("image", help="Path to input image")
    parser.add_argument("--save", action="store_true", help="Save annotated image")
    parser.add_argument("--conf", type=float, default=0.25, help="Confidence threshold")
    args = parser.parse_args()
    run(args.image, save=args.save, conf=args.conf)
