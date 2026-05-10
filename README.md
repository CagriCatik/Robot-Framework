<div align="center">

# Robot Framework

A comprehensive, beginner-friendly documentation and automation project designed for testing activities using Robot Framework.

<img src="https://robotframework.org/img/RF.svg" alt="Robot Framework logo" width="220" />

<br>

[![Robot Framework](https://img.shields.io/badge/Robot_Framework-6.1+-000000.svg?logo=robot-framework)](https://robotframework.org/)
[![Python](https://img.shields.io/badge/Python-3.8+-blue.svg?logo=python&logoColor=white)](https://www.python.org/)
[![MkDocs Material](https://img.shields.io/badge/Docs-MkDocs_Material-526CFE?logo=materialformkdocs)](https://cagricatik.github.io/Robot-Framework/)
[![OpenCV](https://img.shields.io/badge/Computer_Vision-OpenCV-5C3EE8.svg?logo=opencv&logoColor=white)](https://opencv.org/)

</div>

A comprehensive, beginner-friendly documentation and automation project designed for testing activities using **Robot Framework**.

It is tailored for learners, QA engineers, and developers who want a practical path from Robot Framework basics to advanced real-world usage, including custom computer vision integration for non-standard UIs.

---

##  Overview

This project provides organized documentation and hands-on examples for effectively learning and utilizing Robot Framework. It combines standard web automation with advanced techniques like Custom Python Libraries and Computer Vision for complex graphical interfaces.

### Key Features
- **Robot Framework Best Practices:** Clean project structure, naming conventions (TC_XX), and reusable resource files.
- **Modern UI Automation:** Testing high-fidelity web interfaces featuring Glassmorphism and dynamic CSS animations.
- **Custom Python Libraries:** Seamless integration of Python logic (e.g., dynamic test data generation) into Robot keywords.
- **Computer Vision Integration:** Utilizing OpenCV and EasyOCR to automate interaction with non-standard, custom-rendered UIs (e.g., Automotive Infotainment).
- **Beautiful Documentation:** Clean, modern documentation generated with MkDocs Material.
- **CI/CD Ready:** Integrated GitHub Actions for automated documentation deployment.

---

## Project Structure

```shell
.
├── best-practices/       # Showcase for modern web automation & enterprise standards
│   ├── libraries/        # Custom Python Libraries
│   ├── resources/        # Reusable Page Objects and Browser Keywords
│   ├── tests/            # Advanced Test Suites (Login, Checkout, User MGMT)
│   ├── web/              # Modern Demo Web Application
│   └── run_tests.bat     # One-click test execution script
├── dev/                  # Development resources and Keyword Cheat-Sheets
├── docs/                 # Markdown documentation sources
├── learning-lab/         # Hands-on practice and exercises
├── project/              # Core automation project files
├── simulator/            # UI simulation scripts
├── tutorials/            # Step-by-step guides and examples
├── requirements-rf.txt   # Robot Framework & Computer Vision dependencies
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

3. **Run the Best Practices Suite**:
Navigate to the `best-practices/` directory and execute the tests:
```powershell
cd best-practices
.\run_tests.bat
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
- Learning Robot Framework from scratch with modern standards.
- Training automation engineers on advanced web and UI testing.
- Implementing Computer Vision (OpenCV/EasyOCR) for non-standard interfaces.
- Maintaining a searchable, centralized QA knowledge base.
