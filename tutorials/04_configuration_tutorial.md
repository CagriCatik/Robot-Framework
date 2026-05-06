# Tutorial 04 — Project Configuration and IDE Setup

## The Scenario

You can run tests from the terminal, but the team uses VS Code and you keep getting red squiggles under every keyword. Imports resolve when you run `robot` but not in the editor. You also want linting and formatting to run automatically before commits.

This tutorial sets up VS Code correctly, explains why `${CURDIR}` is safer than relative paths, and shows what happens when linting catches a real problem.

## Step 1 — Point VS Code at the Right Python

The Robot Framework Language Server needs to know which Python has your packages installed. Without this setting it will not resolve keywords from SeleniumLibrary or any other external library.

Create or update `.vscode/settings.json` in the project root:

```json
{
  "robot.language-server.python": "${workspaceFolder}/.venv/Scripts/python.exe",
  "robot.python.executable": "${workspaceFolder}/.venv/Scripts/python.exe",
  "robot.pythonpath": [
    "${workspaceFolder}",
    "${workspaceFolder}/libraries"
  ]
}
```

On macOS or Linux, use `/.venv/bin/python` instead of `/.venv/Scripts/python.exe`.

After saving, open any `.robot` file. Hover over `SeleniumLibrary` in a `Library` setting — you should see its documentation popup. Hover over `Click Button` — you should see the keyword signature. If you still see red underlines, reload VS Code (`Ctrl+Shift+P → Reload Window`).

## Step 2 — Understand `${CURDIR}` vs `${EXECDIR}`

This is the single most common path-related mistake in Robot Framework projects.

Create `tests/config_path_demo.robot`:

```robot
*** Test Cases ***
Show Path Variables
    Log    CURDIR:  ${CURDIR}     # directory of THIS file
    Log    EXECDIR: ${EXECDIR}    # directory where robot was invoked
```

Run from the project root:

```powershell
robot -d results tests/config_path_demo.robot
```

Open `log.html`. The two values will differ:

```text
CURDIR:  C:\...\Robot-Framework\tests
EXECDIR: C:\...\Robot-Framework
```

Now run from inside `tests/`:

```powershell
cd tests
robot -d ..\results config_path_demo.robot
```

- `CURDIR` is still `…\tests` (tied to the file location, never changes)
- `EXECDIR` is now `…\tests` (moved with the terminal)

**Rule**: Use `${CURDIR}` for imports because it works regardless of where you invoke `robot`. Use `${EXECDIR}` only for things like the simulator URL where you always run from the project root.

### Practical Example

A resource import that breaks when run from a subdirectory:

```robot
# FRAGILE — depends on the terminal being in the project root
Resource    resources/common.resource
```

A resource import that always works:

```robot
# SAFE — always resolves relative to this file
Resource    ${CURDIR}/../resources/common.resource
```

## Step 3 — Set Up Linting with Robocop

Robocop is a static analysis tool for `.robot` files. It catches common mistakes before you run a test.

Install:

```powershell
pip install robotframework-robocop
```

Run on your test files so far:

```powershell
robocop tests/
```

You will likely see warnings like:

```text
W0301 not-capitalized-test-case-title     tests/01_first_test.robot:12
I0602 too-few-calls-in-test-case          tests/01_first_test.robot:42
```

These are informational — Robocop does not fail your tests, it just reports style issues.

### Intentional Linting Violation

Create `tests/lint_demo.robot` with a known bad pattern:

```robot
*** Settings ***
Library   SeleniumLibrary

*** Test Cases ***
test1
    Open Browser    file:///simulator/index.html   chrome
    sleep    3s
    Click Button   id:app-icon-climate
    Close Browser
```

Run Robocop:

```powershell
robocop tests/lint_demo.robot
```

Expect violations including:

- Test case name not title-cased
- `Sleep` usage (use explicit waits instead)
- Missing two-space separators

These are exactly the patterns that cause flaky, unmaintainable tests. Robocop teaches the rules before they bite you in production.

Delete `tests/lint_demo.robot` when done.

## Step 4 — Configure Result Hygiene

Results should never be committed to Git. Add this to `.gitignore` in the project root (or create it if missing):

```gitignore
# Robot Framework results
results/
output.xml
log.html
report.html

# Virtual environment
.venv/

# Python cache
__pycache__/
*.pyc
*.pyo
```

Always send results to a named folder:

```powershell
robot -d results tests/
```

Never run `robot tests/` without `-d results` — it dumps `output.xml`, `log.html`, and `report.html` into the current directory, which pollutes the project root.

## Step 5 — Validate with Dry Run

Before running a full suite you can validate the structure without opening a browser:

```powershell
robot --dryrun tests/01_first_test.robot
```

Dry run:

- Checks that all imported libraries exist
- Verifies that all keyword references resolve
- Reports syntax errors
- Does **not** execute any keyword bodies (no browser, no assertions, no side effects)

This is your first line of defence before CI runs. If dry run passes and CI still fails, the problem is runtime state (locators, timing, network) rather than syntax.

## Practice Challenge

You have a colleague who wrote this import in a new test file:

```robot
Resource    ..\resources\common.resource
```

It works on their Windows machine when they run `robot` from the project root but fails when the CI runner executes from `tests/`.

Explain why it fails. Rewrite the import so it is portable, and verify the fix with `robot --dryrun`.
