"""
capture_training_data.py — Auto-labelled training data generator.

Opens the simulator in Chrome, captures screenshots at multiple window sizes,
reads each app-icon element's exact pixel position via Selenium, and writes
YOLO-format label files.  Because we KNOW the element IDs we can skip all
manual annotation.

Usage (run from the project root with the venv active):
    python vision/scripts/capture_training_data.py

Output:
    vision/datasets/images/train/*.png   (80 % of samples)
    vision/datasets/images/val/*.png     (20 % of samples)
    vision/datasets/labels/train/*.txt
    vision/datasets/labels/val/*.txt
"""

import os
import random
import shutil
import time
from pathlib import Path

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# ── Configuration ─────────────────────────────────────────────────────────────
PROJECT_ROOT = Path(__file__).resolve().parents[2]
SIMULATOR_URL = (PROJECT_ROOT / "simulator" / "index.html").as_uri()

DATASETS_DIR  = PROJECT_ROOT / "vision" / "datasets"
IMAGES_DIR    = DATASETS_DIR / "images"
LABELS_DIR    = DATASETS_DIR / "labels"

# Class index → (human name, element ID in the simulator)
APP_ICONS = {
    0: ("navigation", "app-icon-navigation"),
    1: ("media",      "app-icon-media"),
    2: ("climate",    "app-icon-climate"),
    3: ("phone",      "app-icon-phone"),
    4: ("vehicle",    "app-icon-vehicle"),
    5: ("settings",   "app-icon-settings"),
    6: ("camera",     "app-icon-camera"),
    7: ("weather",    "app-icon-weather"),
}

# Multiple window sizes produce geometric diversity.
# Each entry is (browser_width, browser_height).
WINDOW_SIZES = [
    (1280, 720),
    (1440, 900),
    (1920, 1080),
    (1366, 768),
    (1600, 900),
]

# Zoom levels simulated via CSS transform on the simulator root element
ZOOM_LEVELS = [1.0, 0.9, 0.95, 1.05]

VAL_SPLIT = 0.20   # fraction of samples held out for validation


# ── Helpers ───────────────────────────────────────────────────────────────────
def build_driver(width: int, height: int) -> webdriver.Chrome:
    options = webdriver.ChromeOptions()
    options.add_argument("--headless=new")
    options.add_argument(f"--window-size={width},{height}")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    return webdriver.Chrome(options=options)


def get_element_rect_in_screenshot(driver, element_id: str) -> dict | None:
    """Returns the element's bounding rect in viewport-pixel space, or None."""
    try:
        el = driver.find_element(By.ID, element_id)
        rect = el.rect   # {'x': ..., 'y': ..., 'width': ..., 'height': ...}
        if rect["width"] <= 0 or rect["height"] <= 0:
            return None
        return rect
    except Exception:
        return None


def rect_to_yolo(rect: dict, img_w: int, img_h: int) -> str:
    """Converts a Selenium element rect to a YOLO label line (normalised)."""
    cx = (rect["x"] + rect["width"]  / 2) / img_w
    cy = (rect["y"] + rect["height"] / 2) / img_h
    bw = rect["width"]  / img_w
    bh = rect["height"] / img_h
    # Clamp to [0, 1] to guard against sub-pixel boundary rounding
    cx = max(0.0, min(1.0, cx))
    cy = max(0.0, min(1.0, cy))
    bw = max(0.0, min(1.0, bw))
    bh = max(0.0, min(1.0, bh))
    return f"{cx:.6f} {cy:.6f} {bw:.6f} {bh:.6f}"


def capture_sample(driver, sample_name: str, split: str) -> bool:
    """
    Takes one screenshot + label file for the current browser state.
    Returns True if at least one icon was successfully labelled.
    """
    img_dir = IMAGES_DIR / split
    lbl_dir = LABELS_DIR / split

    # Raw viewport dimensions from the driver (reliable for page screenshots)
    vp_w = driver.execute_script("return window.innerWidth")
    vp_h = driver.execute_script("return window.innerHeight")

    # Collect labels
    label_lines = []
    for class_id, (name, element_id) in APP_ICONS.items():
        rect = get_element_rect_in_screenshot(driver, element_id)
        if rect is None:
            print(f"  WARN: '{name}' not found in this screenshot")
            continue
        coords = rect_to_yolo(rect, vp_w, vp_h)
        label_lines.append(f"{class_id} {coords}")

    if not label_lines:
        return False

    # Screenshot
    img_path = img_dir / f"{sample_name}.png"
    driver.save_screenshot(str(img_path))

    # Label file (same stem as image)
    lbl_path = lbl_dir / f"{sample_name}.txt"
    lbl_path.write_text("\n".join(label_lines) + "\n")

    print(f"  Saved {img_path.name}  ({len(label_lines)}/8 icons labelled)")
    return True


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    # Recreate dataset directories cleanly
    for split in ("train", "val"):
        for sub in (IMAGES_DIR / split, LABELS_DIR / split):
            if sub.exists():
                shutil.rmtree(sub)
            sub.mkdir(parents=True)

    all_samples = []   # list of (name, split) to distribute

    sample_idx = 0

    for w, h in WINDOW_SIZES:
        for zoom in ZOOM_LEVELS:
            sample_idx += 1
            split = "val" if random.random() < VAL_SPLIT else "train"
            name  = f"sim_{w}x{h}_z{int(zoom*100):03d}_{sample_idx:04d}"

            print(f"Capturing [{split}] {name}  ({w}×{h}  zoom={zoom:.2f})...")

            driver = build_driver(w, h)
            try:
                driver.get(SIMULATOR_URL)
                wait = WebDriverWait(driver, 10)
                wait.until(EC.visibility_of_element_located((By.ID, "screen-home")))
                time.sleep(0.3)   # let animations settle

                # Apply CSS zoom to simulate minor display scale variation
                if zoom != 1.0:
                    driver.execute_script(
                        f"document.getElementById('simulator-root').style.transform = 'scale({zoom})';"
                        "document.getElementById('simulator-root').style.transformOrigin = 'top left';"
                    )
                    time.sleep(0.2)

                ok = capture_sample(driver, name, split)
                if ok:
                    all_samples.append((name, split))
            finally:
                driver.quit()

    # ── Also capture dark mode variant for each size ──────────────────────────
    for w, h in WINDOW_SIZES[:3]:   # only first 3 sizes to avoid too many samples
        sample_idx += 1
        split = "val" if random.random() < VAL_SPLIT else "train"
        name  = f"sim_{w}x{h}_light_{sample_idx:04d}"

        print(f"Capturing [{split}] {name}  (light theme)...")
        driver = build_driver(w, h)
        try:
            driver.get(SIMULATOR_URL)
            wait = WebDriverWait(driver, 10)
            wait.until(EC.visibility_of_element_located((By.ID, "screen-home")))
            # Toggle to light theme
            driver.find_element(By.ID, "app-icon-settings").click()
            time.sleep(0.3)
            driver.find_element(By.ID, "settings-theme-toggle").click()
            time.sleep(0.3)
            driver.find_element(By.ID, "nav-home-button").click()
            wait.until(EC.visibility_of_element_located((By.ID, "screen-home")))
            time.sleep(0.3)

            ok = capture_sample(driver, name, split)
            if ok:
                all_samples.append((name, split))
        finally:
            driver.quit()

    # ── Summary ───────────────────────────────────────────────────────────────
    train_count = sum(1 for _, s in all_samples if s == "train")
    val_count   = sum(1 for _, s in all_samples if s == "val")
    print(f"\nDone. {train_count} train + {val_count} val = {len(all_samples)} total samples")
    print(f"Dataset: {DATASETS_DIR}")


if __name__ == "__main__":
    random.seed(42)
    main()
