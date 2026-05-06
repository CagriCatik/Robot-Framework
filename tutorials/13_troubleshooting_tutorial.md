# Tutorial 13 — Troubleshooting Real Failures

## The Scenario

Your tests were green yesterday. Today CI is red. This tutorial works through the eight most common failure categories you will actually hit, showing exactly what the error looks like and how to fix it — using real examples from the simulator project.

## Debugging Workflow

Always follow this order before guessing:

1. Run `robot --dryrun tests/` — if it fails, the problem is syntax or imports, not runtime
2. If dryrun passes, run the failing test alone with `--loglevel DEBUG`
3. Open `results/log.html` — expand the red keyword
4. Read the full error message, the actual value, and the expected value
5. Fix **one thing** and re-run — do not change multiple things at once

## Failure 1 — "No keyword with name X found"

**Symptom:**

```text
No keyword with name 'Open Climate Screeen' found.
```

**What happened:** Typo in the keyword call. Robot Framework could not find `Open Climate Screeen` (note the triple `e`).

**How to find it:** `robot --dryrun tests/` catches this without opening a browser. All keyword resolution happens at parse time during dry run.

**Fix:**

```robot
# Wrong
Open Climate Screeen

# Correct
Open Climate Screen
```

**Also causes this error:**

- A resource file is not imported (the keyword exists in `climate_page.resource` but `Resource` is missing in `*** Settings ***`)
- A library import failed silently — check the log header for import errors before the first test

## Failure 2 — "Variable X not found"

**Symptom:**

```text
Variable '${TEMP_UP_BTN}' not found.
```

**What happened:** The variable is defined in `climate_page.resource` but the test file does not import that resource.

**How to find it:** Look at `*** Settings ***` in the failing file. Compare it against the resource that defines the variable.

**Fix:**

```robot
*** Settings ***
# Missing import — add this line
Resource    ${CURDIR}/../resources/climate_page.resource
```

**Other causes:**

- Typo in the variable name (`${TEMP_UPP_BTN}` vs `${TEMP_UP_BTN}`)
- Using `%{ENV_VAR}` and the environment variable is not set — override with `-v NAME:value`
- Scope issue: variable was set with `Set Test Variable` in one keyword but referenced after the test ended

## Failure 3 — The One-Space Mistake

**Symptom:**

```text
No keyword with name 'Should Be Equal 22°C 22°C' found.
```

**What happened:** Single space between keyword and arguments. Robot Framework treats the whole line as one keyword name.

```robot
# WRONG — one space makes "Should Be Equal 22°C 22°C" one token
Should Be Equal ${before} ${after}

# CORRECT — two spaces separate keyword from arguments
Should Be Equal    ${before}    ${after}
```

**How to find it:** `robocop tests/` reports this as a `W0301` violation immediately.

## Failure 4 — "Element with locator X not found" (Timing)

**Symptom:**

```text
ElementNotInteractableException: element not interactable
```

or:

```text
NoSuchElementException: no such element: Unable to locate element: {"method":"css selector","selector":"#screen-climate"}
```

**What happened:** The keyword ran before the element appeared in the DOM. The browser navigated but JavaScript had not yet updated the page.

```robot
# WRONG — clicks immediately, screen may not have appeared yet
Click Button    id:app-icon-climate
Element Text Should Be    id:nav-current-screen    CLIMATE

# CORRECT — waits for the screen to be visible before asserting
Click Button    id:app-icon-climate
Wait Until Element Is Visible    id:screen-climate    timeout=3s
Element Text Should Be    id:nav-current-screen    CLIMATE
```

**The rule:** After every navigation action, add a `Wait Until Element Is Visible` before the next interaction. Never `Sleep`.

## Failure 5 — "Importing library X failed"

**Symptom:**

```text
Importing library 'SeleniumLibrary' failed:
No module named 'SeleniumLibrary'
```

**What happened:** The library is not installed in the active virtual environment.

**Diagnosis:**

```powershell
# Step 1 — check which Python is active
python -c "import sys; print(sys.executable)"

# Step 2 — check if the package is there
pip show robotframework-seleniumlibrary
```

**Fix:**

```powershell
# Activate the virtual environment first
.\.venv\Scripts\Activate.ps1

# Then install
pip install -r requirements-rf.txt
```

**Also check:** Library name spelling. `SeleniumLibrary` is case-sensitive. `seleniumlibrary` fails.

## Failure 6 — "Expected N arguments, got M"

**Symptom:**

```text
Keyword 'Set Driver Temperature To' expected 1 argument, got 0.
```

**What happened:** The keyword call is missing an argument.

```robot
# Keyword definition
Set Driver Temperature To
    [Arguments]    ${target_celsius}
    ...

# WRONG call — missing the argument
Set Driver Temperature To

# CORRECT call
Set Driver Temperature To    24
```

**How to find it:** `robot --dryrun` catches argument count mismatches.

## Failure 7 — Element Present but Assertion Wrong

**Symptom:**

```text
AssertionError: Driver temperature: expected 30°C, got 29°C
```

**What happened:** The element was found, but its value does not match the expectation. This is a genuine product bug or a wrong expected value in the test.

**How to investigate:**

1. Open `log.html` and expand the failing `Should Be Equal` call
2. Read the actual value returned — is it `29°C` because the boundary logic is off by one?
3. Run with `--loglevel DEBUG` to see the exact `Get Text` return value

```powershell
robot -d results --loglevel DEBUG -t "Temperature Ceiling Is 30" tests/climate/
```

**In this case:** The simulator clamps at 30°C. If the test clicks up 20 times from 22°C and expects 30°C, verify the boundary with a manual click count first. The assertion is probably correct and the application has a bug.

## Failure 8 — ChromeDriver Version Mismatch

**Symptom:**

```text
SessionNotCreatedException: session not created: This version of ChromeDriver
only supports Chrome version 114. Current browser version is 126.
```

**What happened:** The ChromeDriver binary does not match the installed Chrome browser version.

**Fix (Selenium 4.6+ — automatic driver management):**

```powershell
pip install --upgrade selenium
```

Selenium 4.6+ downloads the correct driver automatically. If you still see this error after upgrading, the cached driver is stale:

```powershell
# Clear the Selenium driver cache
Remove-Item -Recurse -Force "$env:USERPROFILE\.cache\selenium"
```

Then run the tests again. Selenium will re-download the correct driver.

## Failure 9 — Resource File Not Found

**Symptom:**

```text
Resource file '...\resources\does_not_exist.resource' does not exist.
```

**What happened:** The path in `Resource` does not resolve.

```robot
# FRAGILE — depends on where robot is invoked from
Resource    resources/climate_page.resource

# SAFE — always resolves relative to this file's location
Resource    ${CURDIR}/../resources/climate_page.resource
```

**Quick test:** Run `robot --dryrun tests/` from different directories and see if it still resolves.

## Failure 10 — Test Passes in Isolation, Fails in Suite

**What happened:** Tests are sharing state. One test changes something (volume, theme, temperature) and the next test inherits the unexpected state.

**Diagnosis:** Run the failing test alone:

```powershell
robot -d results -t "Failing Test Name" tests/climate/
```

If it passes alone but fails in the full suite, the test has a state dependency.

**Fix:** Use `Test Setup` to reset to a known state before each test. Never assume the previous test left the application in a specific state.

```robot
*** Settings ***
Test Setup    Go To Home Screen    # reload the page to a clean state
```

Or for climate tests:

```robot
Test Setup    Run Keywords
...    Go To    ${SIMULATOR_URL}
...    AND    Wait Until Element Is Visible    id:screen-home    timeout=5s
...    AND    Click Button    id:app-icon-climate
...    AND    Wait Until Element Is Visible    id:screen-climate    timeout=3s
```

## Quick Reference

| Error message | First thing to check |
| --- | --- |
| `No keyword with name` | Typo? Missing resource import? Run `--dryrun` |
| `Variable not found` | Typo? Missing resource import? Scope issue? |
| `expected N arguments, got M` | Match `[Arguments]` to the call site |
| `No module named X` | Activate venv, then `pip install -r requirements-rf.txt` |
| `Element not found` | Add `Wait Until Element Is Visible` before the interaction |
| `SessionNotCreatedException` | Upgrade Selenium, clear driver cache |
| `Resource file does not exist` | Use `${CURDIR}` in the import path |
| `expected X got Y` | Real product bug or wrong expected value — check in browser first |
| Passes alone, fails in suite | State dependency — add `Test Setup` to reset to known state |

## Practice Challenge

Introduce each of the following bugs into `tests/climate_tests.robot`, run the suite, find the error in `log.html`, and fix it:

1. Add a typo: `Raise Temperature To Maximumm`
2. Remove the `Resource` import for `climate_page.resource`
3. Change one `Should Be Equal` to compare `30°C` with `31°C`
4. Remove the `Wait Until Element Is Visible` line after clicking the climate icon

For each bug: run `--dryrun` first, then run normally with `--loglevel DEBUG`, and document which of the two steps caught the problem.
