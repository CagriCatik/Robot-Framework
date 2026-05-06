<div align="center">

# Robot Framework for Automotive Infotainment

<img src="https://robotframework.org/img/RF.svg" alt="Robot Framework logo" width="220" />

<br>

[![Robot Framework](https://img.shields.io/badge/Robot_Framework-6.1+-000000.svg?logo=robot-framework)](https://robotframework.org/)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg?logo=python&logoColor=white)](https://www.python.org/)
[![MkDocs Material](https://img.shields.io/badge/Docs-MkDocs_Material-526CFE?logo=materialformkdocs)](https://cagricatik.github.io/Robot-Framework/)
[![OpenCV](https://img.shields.io/badge/Computer_Vision-OpenCV-5C3EE8.svg?logo=opencv&logoColor=white)](https://opencv.org/)

</div>

A comprehensive, beginner-friendly documentation and automation project designed for testing **Automotive Infotainment Systems** using **Robot Framework**.

It is tailored for learners, QA engineers, and developers who want a practical path from Robot Framework basics to advanced real-world usage, including custom computer vision integration for non-standard UIs.

---

##  Overview

This project provides organized documentation and hands-on examples for effectively learning and utilizing Robot Framework. It specifically highlights automation techniques relevant to complex graphical interfaces found in automotive environments.

### Key Features
- **Robot Framework Fundamentals:** Test case structure, syntax, keywords, and variables.
- **Advanced Automation:** Custom Python libraries, resource files, and test suites.
- **Computer Vision Integration:** Utilizing OpenCV and EasyOCR to automate interaction with non-standard, custom-rendered infotainment UIs.
- **Hands-on Labs:** Interactive `learning-lab/` and `tutorials/` for practical experience.
- **Beautiful Documentation:** Clean, modern documentation generated with MkDocs Material.
- **CI/CD Deployment:** Automated deployment of documentation to GitHub Pages via GitHub Actions.

---

## Project Structure

```shell
.
├── docs/                 # Markdown documentation sources
├── learning-lab/         # Hands-on practice and exercises
├── project/              # Core automation project files
├── simulator/            # Infotainment UI simulation scripts
├── tutorials/            # Step-by-step guides and examples
├── .github/workflows/    # CI/CD pipelines (MkDocs Deploy)
├── mkdocs.yml            # MkDocs site configuration
├── requirements-rf.txt   # Robot Framework & Computer Vision dependencies
├── requirements-docs.txt # Python dependencies for building the docs
└── run.bat               # Windows script for local setup and preview
```

---

## Getting Started

### Prerequisites

Ensure you have the following installed:
- Python 3.8+
- Git
- Windows Command Prompt or PowerShell

### Local Setup (Windows)

1. Clone this repository:
```bash
git clone https://github.com/CagriCatik/Robot-Framework
cd Robot-Framework
```

2. Run the automated setup script to build the virtual environment, install dependencies, and launch the docs server:
```bat
run.bat
```

3. Open the documentation in your browser:
```text
http://127.0.0.1:8000
```

---

## Manual Installation & Usage

If you prefer to set up the environment manually:

### 1. Virtual Environment
```bash
python -m venv .venv
.venv\Scripts\activate
```

### 2. Install Dependencies

For **Documentation**:
```bash
pip install -r requirements-docs.txt
```

For **Automation (Robot Framework, OpenCV, EasyOCR)**:
```bash
pip install -r requirements-rf.txt
```

### 3. Serving Documentation locally
```bash
mkdocs serve
```

### 4. Running Tests
*(Navigate to the appropriate project directory, e.g., `project/` or `learning-lab/`)*
```bash
robot -d results tests/
```

---

## Documentation Workflow

The documentation source files are stored in the `docs/` directory.

1. Edit or add Markdown files inside `docs/`.
2. Update navigation in `mkdocs.yml` if needed.
3. Review changes locally using `mkdocs serve`.
4. Commit and push your changes to the `main` branch. 
5. GitHub Actions will automatically build and deploy the updated site.

---

## Recommended Use Cases

This project is highly beneficial for:
- Learning Robot Framework from scratch.
- Training automation engineers on automotive/infotainment testing.
- Implementing Computer Vision (OpenCV/EasyOCR) in test automation.
- Maintaining a searchable, centralized QA knowledge base.
