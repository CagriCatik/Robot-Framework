*** Settings ***
Documentation    YOLO11 object detection tests for the automotive simulator.
...              Prerequisite: run the training pipeline before executing these tests.
...
...              Setup:
...                python vision/scripts/capture_training_data.py
...                python vision/scripts/train.py
...
...              Run:
...                robot -d vision/results vision/tests/
Test Tags    vision    object-detection
