# Installation Guide

This guide walks you through the installation of Python and Robot Framework, including the libraries used in this project.

## Step 1: Install Python

Robot Framework requires Python 3.8 or higher.

1. Visit [python.org/downloads](https://python.org/downloads/).
2. Download the latest stable version of Python (3.8 or higher).
3. **Important**: During installation, check the box **"Add Python to PATH"**.
4. (Optional) Choose "Customize installation" to define a specific directory (e.g., `C:\Python311`).
5. Verify the installation:

```bash
python --version
```

## Step 2: Verify pip

`pip` is Python's package manager and is bundled with Python 3.4+.

```bash
pip --version
```

If `pip` is missing, reinstall Python and ensure the pip component is selected during setup.

## Step 3: Create a Virtual Environment (Recommended)

Using a virtual environment isolates project dependencies from your system Python installation.

```bash
# Create the virtual environment
python -m venv .venv

# Activate it (Windows PowerShell)
.venv\Scripts\Activate.ps1

# Activate it (Windows CMD)
.venv\Scripts\activate.bat

# Activate it (macOS / Linux)
source .venv/bin/activate
```

Once activated, all `pip install` commands install packages into the virtual environment only.

To deactivate:

```bash
deactivate
```

## Step 4: Install Robot Framework

### Latest Version

```bash
pip install robotframework
```

### Specific Version

```bash
pip install robotframework==6.1.1
```

### Upgrading

```bash
pip install --upgrade robotframework
```

## Step 5: Install Project Libraries

This project uses the following libraries (defined in `requirements-rf.txt`):

```text
robotframework>=6.1.1
robotframework-seleniumlibrary>=6.1.3
robotframework-requests>=0.9.5
webdriver-manager>=4.0.1
```

Install them all at once:

```bash
pip install -r requirements-rf.txt
```

### SeleniumLibrary

SeleniumLibrary provides keywords for controlling web browsers.

```bash
pip install robotframework-seleniumlibrary
```

### RequestsLibrary

RequestsLibrary provides keywords for HTTP API testing.

```bash
pip install robotframework-requests
```

### webdriver-manager

`webdriver-manager` automatically downloads and manages the correct browser driver binary (ChromeDriver, GeckoDriver, etc.).

```bash
pip install webdriver-manager
```

Usage in a robot test with `webdriver-manager`:

```robot
*** Settings ***
Library    SeleniumLibrary
Library    webdriver_manager.chrome    WITH NAME    WDM

*** Test Cases ***
Open Browser With Managed Driver
    ${driver_path}=    WDM.Install    # downloads ChromeDriver if needed
    Open Browser    https://example.com    chrome
    ...    executable_path=${driver_path}
```

> [!NOTE]
> Modern versions of SeleniumLibrary (6.x) together with Selenium 4.6+ use Selenium Manager built-in, which handles driver downloads automatically without needing `webdriver-manager` explicitly. You can simply call `Open Browser` without specifying a driver path.

## Step 6: Verify Installation

```bash
robot --version
```

Expected output (version numbers will vary):

```text
Robot Framework 6.1.1 (Python 3.11.x on win32)
```

Verify all libraries installed correctly:

```bash
pip show robotframework robotframework-seleniumlibrary robotframework-requests webdriver-manager
```

## Step 7: Freeze Dependencies

Once your environment is set up, export the exact versions for reproducible builds:

```bash
pip freeze > requirements-lock.txt
```

## Quick Reference

| Command | Purpose |
| ------- | ------- |
| `python -m venv .venv` | Create virtual environment |
| `.venv\Scripts\activate` | Activate venv (Windows) |
| `pip install -r requirements-rf.txt` | Install all project deps |
| `robot --version` | Verify RF installation |
| `pip show robotframework` | Show installed RF details |
| `pip install --upgrade robotframework` | Upgrade to latest RF |

---

> [!NOTE]
> If you see `robot is not recognized as an internal or external command`, ensure that your Python `Scripts` directory is in your system PATH. See [Configuration & IDE Setup](04_configuration.md) for instructions.

---

*Next: [Configuration & IDE Setup](04_configuration.md)*
