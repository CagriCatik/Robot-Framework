# Tutorial 03 — Installation and Environment Verification

## The Scenario

A new team member has cloned the repository and needs a working environment within 15 minutes. This tutorial covers every step from zero to a green test run against the simulator, including the failure modes you will actually hit.

## Step 1 — Check Python

Open PowerShell and run:

```powershell
python --version
pip --version
```

You need Python 3.8 or newer. If `python` is not found:

1. Download from [python.org/downloads](https://python.org/downloads/)
2. During installation, check **Add Python to PATH**
3. Open a **new** terminal (PATH changes only apply to new windows)

If `pip` is missing but `python` works, Python is installed but the Scripts folder is not on PATH. Use `python -m pip` as a workaround until PATH is fixed.

## Step 2 — Create a Virtual Environment

A virtual environment keeps project dependencies isolated. Without it, installing packages from different projects on the same machine can conflict.

From the **repository root**:

```powershell
python -m venv .venv
```

Activate it:

```powershell
# Windows PowerShell
.\.venv\Scripts\Activate.ps1

# Windows CMD
.\.venv\Scripts\activate.bat

# macOS / Linux
source .venv/bin/activate
```

Your prompt changes to show `(.venv)`. Every `pip install` from now on installs into this environment, not your system Python.

**If PowerShell blocks activation** with an execution policy error:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Then activate again.

## Step 3 — Install the Project Dependencies

```powershell
pip install -r requirements-rf.txt
```

The file installs:

```text
robotframework>=6.1.1
robotframework-seleniumlibrary>=6.1.3
robotframework-requests>=0.9.5
webdriver-manager>=4.0.1
```

**Do not** use `pip install robotframework` alone. That installs only the core framework, which is not enough to run browser tests.

## Step 4 — Verify the Installation

Run all three checks:

```powershell
robot --version
python -m robot --version
pip show robotframework robotframework-seleniumlibrary
```

Expected output from `robot --version`:

```text
Robot Framework 6.x.x (Python 3.x.x on win32)
```

If `robot` is not recognized but `python -m robot` works, your Python Scripts directory is not on PATH. Either fix PATH (see Tutorial 04) or always use `python -m robot` for now.

## Step 5 — Run the Verification Suite

A small self-contained test suite is provided to confirm the environment works:

```powershell
robot -d results tutorials/03_install_check.robot
```

Create `tutorials/03_install_check.robot`:

```robot
*** Settings ***
Documentation    Verifies that Robot Framework and SeleniumLibrary are installed correctly.
Library          SeleniumLibrary
Library          Collections
Library          String

*** Variables ***
${SIMULATOR_URL}    file:///${EXECDIR}/simulator/index.html
${BROWSER}          chrome

*** Test Cases ***
Robot Framework Version Is 6 Or Newer
    ${version}=    Evaluate    int(__import__('robot').version.VERSION.split('.')[0])    modules=robot
    Should Be True    ${version} >= 6    Robot Framework version must be 6 or newer, got ${version}

SeleniumLibrary Is Importable
    ${lib}=    Evaluate    __import__('SeleniumLibrary')    modules=SeleniumLibrary
    Should Not Be Equal    ${lib}    ${None}

Simulator File Exists
    ${path}=    Set Variable    ${EXECDIR}/simulator/index.html
    File Should Exist    ${path}
    ...    msg=Simulator not found at ${path}. Check that you are running from the project root.

Browser Can Open The Simulator
    [Tags]    browser
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Wait Until Element Is Visible    id:screen-home    timeout=8s
    ${title}=    Get Title
    Should Contain    ${title}    AutoCenter
    [Teardown]    Close Browser
```

Run:

```powershell
robot -d results tutorials/03_install_check.robot
```

All four tests should be green. The last one opens Chrome, loads the simulator, and verifies the page title.

## Step 6 — Understand What Each Result File Is For

After the run, `results/` contains:

```text
results/
├── output.xml     Machine-readable execution data. CI tools consume this.
├── log.html       Keyword-level step-by-step view. Open this to debug failures.
└── report.html    Pass/fail summary with tag and suite statistics.
```

Open `results/log.html` now even though the tests passed. Expand any keyword. Notice:

- The library that provided the keyword (`SeleniumLibrary`, `BuiltIn`, etc.)
- The arguments that were passed
- The return value (if any)
- The time each keyword took

You will read this file every time something breaks.

## Common Installation Problems

| Symptom | Cause | Fix |
| --- | --- | --- |
| `robot` not recognized | Scripts dir not on PATH | Use `python -m robot`, then fix PATH |
| `Importing library SeleniumLibrary failed` | Package not installed in active venv | Activate `.venv`, then `pip install -r requirements-rf.txt` |
| `File should exist` test fails | Running `robot` from the wrong directory | `cd` to the project root first |
| Chrome does not open | Selenium driver mismatch | Selenium 4.6+ auto-downloads — ensure Selenium is up to date |
| `Set-ExecutionPolicy` denied | No admin rights for system policy | Use `-Scope CurrentUser` as shown above |

## Practice Challenge

Without looking at Tutorial 04, figure out why the `Simulator File Exists` test would fail if you ran the same `robot` command from inside the `tutorials/` folder instead of the project root.

Fix the test so it works regardless of which directory `robot` is invoked from. Hint: look at what `${EXECDIR}` and `${CURDIR}` each resolve to.
