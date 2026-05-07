"""
train.py — Fine-tune YOLO11 nano on the simulator icon dataset.

Usage (run from the project root with the venv active):
    python vision/scripts/train.py

Output:
    vision/model/simulator_icons.pt   ← best-weights model for RF tests
    vision/model/training_run/        ← full training artefacts
"""

import os
import shutil
import tempfile
from pathlib import Path

import yaml
from ultralytics import YOLO

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATASET_YAML = PROJECT_ROOT / "vision" / "datasets" / "dataset.yaml"
MODEL_DIR    = PROJECT_ROOT / "vision" / "model"
FINAL_MODEL  = MODEL_DIR / "simulator_icons.pt"
TRAINING_RUN = MODEL_DIR / "training_run"

EPOCHS   = 80
IMG_SIZE = 640
BATCH    = 8
PATIENCE = 20
WORKERS  = 0


def make_absolute_yaml(source_yaml: Path) -> str:
    """
    Ultralytics resolves the 'path' key in dataset.yaml relative to its
    global settings datasets_dir, not the yaml file itself.  This helper
    writes a temporary yaml where 'path' is the absolute directory so
    Ultralytics can always find the images regardless of settings.
    """
    with open(source_yaml) as fh:
        data = yaml.safe_load(fh)

    # Replace the relative path with the absolute datasets directory
    data["path"] = str(source_yaml.parent)

    tmp = tempfile.NamedTemporaryFile(
        mode="w", suffix=".yaml", delete=False, encoding="utf-8"
    )
    yaml.dump(data, tmp, allow_unicode=True)
    tmp.close()
    return tmp.name


def main():
    MODEL_DIR.mkdir(parents=True, exist_ok=True)

    # Verify training data exists
    train_images = PROJECT_ROOT / "vision" / "datasets" / "images" / "train"
    n_train = len(list(train_images.glob("*.png"))) if train_images.exists() else 0
    if n_train == 0:
        raise RuntimeError(
            "No training images found.\n"
            "Run:  python vision/scripts/capture_training_data.py"
        )
    print(f"Training images found: {n_train}")

    # Write a temp yaml with the absolute dataset path
    tmp_yaml = make_absolute_yaml(DATASET_YAML)
    print(f"Dataset config (absolute): {tmp_yaml}")

    try:
        print("Loading YOLO11n base model …")
        model = YOLO("yolo11n.pt")

        print(f"Training for {EPOCHS} epochs …")
        results = model.train(
            data     = tmp_yaml,
            epochs   = EPOCHS,
            imgsz    = IMG_SIZE,
            batch    = BATCH,
            patience = PATIENCE,
            workers  = WORKERS,
            project  = str(TRAINING_RUN),
            name     = "run",
            exist_ok = True,
            verbose  = True,
        )
    finally:
        os.unlink(tmp_yaml)

    # Copy best weights to the known output path
    best = Path(results.save_dir) / "weights" / "best.pt"
    last = Path(results.save_dir) / "weights" / "last.pt"
    src  = best if best.exists() else last

    if src.exists():
        shutil.copy(src, FINAL_MODEL)
        print(f"\nModel saved: {FINAL_MODEL}")
    else:
        print("\nWARNING: No weights produced.")
        return

    print(f"  mAP50    : {results.results_dict.get('metrics/mAP50(B)', 'n/a')}")
    print(f"  mAP50-95 : {results.results_dict.get('metrics/mAP50-95(B)', 'n/a')}")
    print("\nTraining complete.")


if __name__ == "__main__":
    main()
