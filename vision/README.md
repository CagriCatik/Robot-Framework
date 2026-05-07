# Vision — YOLO11 Object Detection for the Simulator

Detects the 8 app icons on the automotive simulator home screen using a
YOLO11 nano model fine-tuned on auto-labelled screenshots.

```shell
vision/
├── datasets/
│   ├── dataset.yaml          class definitions (8 icons)
│   ├── images/train/         auto-generated screenshots (80 %)
│   ├── images/val/           auto-generated screenshots (20 %)
│   ├── labels/train/         YOLO .txt label files
│   └── labels/val/
├── model/
│   ├── simulator_icons.pt    trained model (produced by train.py)
│   └── training_run/         full training artefacts
├── scripts/
│   ├── capture_training_data.py   generates dataset from the live simulator
│   ├── train.py                   fine-tunes YOLO11n on the dataset
│   └── infer.py                   quick CLI inference on any image
├── libraries/
│   └── SimulatorVision.py         Robot Framework keyword library
├── tests/
│   ├── __init__.robot
│   └── app_icon_detection.robot   RF test suite
├── results/                       screenshots + annotated outputs
└── requirements-vision.txt
```

## Setup

```powershell
# 1. Activate the project venv
.\.venv\Scripts\Activate.ps1

# 2. Install vision dependencies (ultralytics is the only new one)
pip install -r vision/requirements-vision.txt

# 3. Generate training data from the live simulator
#    Opens headless Chrome, captures ~23 labelled screenshots
python vision/scripts/capture_training_data.py

# 4. Train the model (~15 min CPU / ~2 min GPU)
python vision/scripts/train.py
```

## Run the RF Tests

```powershell
# Full suite
robot -d vision/results vision/tests/

# Smoke tests only (model load + full-grid detection)
robot -d vision/results -i smoke vision/tests/

# Single icon
robot -d vision/results -i navigation vision/tests/
```

## Quick Inference (CLI)

```powershell
# Detect on any PNG screenshot
python vision/scripts/infer.py learning-lab/results/steps/step_001__open_browser__url.png

# Save annotated image
python vision/scripts/infer.py some_screenshot.png --save
```

## Detected Classes

| Class ID | Name | Grid Position |
| --- | --- | --- |
| 0 | navigation | Row 1, Col 1 |
| 1 | media | Row 1, Col 2 |
| 2 | climate | Row 1, Col 3 |
| 3 | phone | Row 1, Col 4 |
| 4 | vehicle | Row 2, Col 1 |
| 5 | settings | Row 2, Col 2 |
| 6 | camera | Row 2, Col 3 |
| 7 | weather | Row 2, Col 4 |

## Available RF Keywords

```robot
Load Vision Model                          # load / reload the .pt file
Detect Icons In Screenshot    path         # returns list of dicts
App Icon Should Be Detected    path    name    min_conf=0.30
App Icon Should Not Be Detected    path    name
All App Icons Should Be Detected    path   # all 8
Icons In Top Row Should Be Detected    path
Icons In Bottom Row Should Be Detected    path
Detection Count Should Be    path    8
Icon Confidence Should Be Above    path    name    0.70
Get Icon Bounding Box    path    name        # returns {x1,y1,x2,y2,cx,cy,confidence}
Get Detection Summary    path               # returns {count, names, missing}
Save Annotated Screenshot    path    out    # saves bounding-box overlay PNG
```

## Confidence Thresholds

| Situation | Recommended threshold |
| --- | --- |
| Normal smoke test | `0.30` |
| High-reliability check | `0.60` |
| Position tests | `0.30` (just need one hit) |

## Architecture

```
Selenium screenshot  →  YOLO11n inference  →  RF assertions
                              ↑
              fine-tuned on simulator screenshots
              (auto-labelled — no manual annotation)
```
