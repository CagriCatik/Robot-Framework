# Troubleshooting

Automation projects often run into similar issues. This guide covers the most common problems and their solutions.

## 1. Syntax Errors

### The "One Space" Mistake

Robot Framework requires **at least two spaces** (or a tab) between a keyword and its arguments. A single space makes Robot treat the whole line as one keyword name.

- **Problem**: `No keyword with name 'Log Hello World' found.`
- **Cause**: `Log Hello World` — only one space between `Log` and its argument.
- **Fix**: Use two spaces: `Log    Hello World`

```robot
# WRONG
Log Hello World

# CORRECT
Log    Hello World
```

### Deprecated List/Dict Syntax

- **Problem**: Warning `Accessing list variable as scalar is deprecated`.
- **Cause**: Using `@{list}[index]` to access an individual item.
- **Fix**: Always use `${list}[index]` for individual items.

```robot
# WRONG (deprecated)
Log    @{MY_LIST}[0]

# CORRECT
Log    ${MY_LIST}[0]
```

### Continuation Marker Indentation

- **Problem**: `Non-default argument after default arguments.` or unexpected parse errors on multi-line definitions.
- **Cause**: The `...` continuation marker must be at the same indentation level as the line it continues.

```robot
# WRONG — continuation at wrong level
*** Settings ***
Resource    ../resources/common.resource
  ...    ../resources/login_page.resource

# CORRECT
*** Settings ***
Resource    ../resources/common.resource
...         ../resources/login_page.resource
```

## 2. Environment Issues

### `robot` Command Not Recognized

- **Problem**: `'robot' is not recognized as an internal or external command.`
- **Diagnosis**:

```bash
pip show robotframework      # check if installed
python -m robot --version    # try invoking via python module
```

- **Fix**:
  1. If not installed: `pip install robotframework`
  2. If installed but not in PATH: add `C:\Python3xx\Scripts` to your system's `Path` environment variable.
  3. Alternatively, always invoke as `python -m robot tests/`.

### Library Import Failure

- **Problem**: `Importing library 'SeleniumLibrary' failed: No module named 'SeleniumLibrary'`
- **Causes and fixes**:

| Cause | Fix |
| ----- | --- |
| Library not installed | `pip install robotframework-seleniumlibrary` |
| Wrong name in settings | Check case: `SeleniumLibrary` not `seleniumlibrary` |
| Wrong virtual environment active | Activate the correct `.venv` first |
| Library installed globally, but test runs inside `.venv` | Install inside the venv: `.venv\Scripts\pip install robotframework-seleniumlibrary` |

### Resource File Not Found

- **Problem**: `Resource file '../resources/common.resource' does not exist.`
- **Fix**: Verify the path is relative to the file containing the `Resource` statement, not relative to the working directory. Use `${CURDIR}` for portability:

```robot
*** Settings ***
Resource    ${CURDIR}/../resources/common.resource
```

### Module Not Found for Custom Library

- **Problem**: `Importing library '../libraries/MyLib.py' failed`.
- **Fix**: Either use an absolute path, or add the library directory to Python's path using `--pythonpath`:

```bash
robot --pythonpath libraries tests/
```

Or set `PYTHONPATH` in the environment:

```bash
set PYTHONPATH=%CD%\libraries    # Windows CMD
$env:PYTHONPATH = "$PWD\libraries"  # Windows PowerShell
export PYTHONPATH="$PWD/libraries"  # macOS/Linux
```

## 3. Argument Mismatches

- **Problem**: `Keyword 'Login With Credentials' expected 2 arguments, got 1.`
- **Fix**: Count the `[Arguments]` in the keyword definition and match them in the call.

```robot
# Keyword definition expects 2 arguments
*** Keywords ***
Login With Credentials
    [Arguments]    ${username}    ${password}
    ...

# WRONG — only 1 argument passed
Login With Credentials    admin

# CORRECT — 2 arguments passed
Login With Credentials    admin    secret
```

## 4. Browser and WebDriver Issues

### ChromeDriver Version Mismatch

- **Problem**: `SessionNotCreatedException: Message: session not created: This version of ChromeDriver only supports Chrome version XX`
- **Fix (Option 1)**: Use Selenium 4.6+ with built-in Selenium Manager — it auto-downloads the correct driver. No manual driver management needed.
- **Fix (Option 2)**: Use `webdriver-manager` to auto-manage drivers:

```python
# conftest.py or a setup keyword
from webdriver_manager.chrome import ChromeDriverManager
from selenium import webdriver
driver = webdriver.Chrome(ChromeDriverManager().install())
```

- **Fix (Option 3)**: Manually download ChromeDriver matching your Chrome version from [chromedriver.chromium.org](https://chromedriver.chromium.org) and add it to PATH.

### Browser Not Opening (Headless Environments)

- **Problem**: Tests fail immediately with a browser error in CI (no display).
- **Fix**: Use headless mode:

```robot
*** Keywords ***
Open Browser Headless
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    modules=sys
    Call Method    ${options}    add_argument    --headless
    Call Method    ${options}    add_argument    --no-sandbox
    Call Method    ${options}    add_argument    --disable-dev-shm-usage
    Create Webdriver    Chrome    options=${options}
    Go To    ${BASE_URL}
```

Or use the simpler `options` argument available in newer SeleniumLibrary versions:

```robot
Open Browser    ${BASE_URL}    chrome    options=add_argument("--headless")
```

### Element Not Found / Timing Issues

- **Problem**: `Element with locator 'id:submit' not found.`
- **Cause**: The element is not yet present in the DOM when the keyword runs.
- **Fix**: Use explicit waits instead of `Sleep`:

```robot
# BAD — brittle timing
Sleep    3s
Click Button    id:submit

# GOOD — waits up to the implicit timeout
Wait Until Element Is Visible    id:submit
Click Button    id:submit

# BETTER — combined
Wait Until Element Is Enabled    id:submit    timeout=10s
Click Button    id:submit
```

## 5. RequestsLibrary Issues

### Session Not Found

- **Problem**: `No session created with alias 'my_api'.`
- **Cause**: `Create Session` was not called before using `GET On Session` / `POST On Session`.
- **Fix**: Call `Create Session` in Suite Setup or before the request:

```robot
*** Settings ***
Suite Setup    Create Session    my_api    ${API_URL}

*** Test Cases ***
Get Users
    ${resp}=    GET On Session    my_api    /users
    Should Be Equal As Integers    ${resp.status_code}    200
```

### SSL Certificate Errors

- **Problem**: `SSLError: certificate verify failed`
- **Fix** (for non-production testing only): Disable SSL verification:

```robot
Create Session    my_api    ${API_URL}    verify=${FALSE}
```

## 6. Variable Issues

### Variable Not Defined

- **Problem**: `Variable '${MY_VAR}' not found.`
- **Causes**:
  - Typo in the variable name.
  - Variable set in a keyword but used outside its scope. See [Variable Scope](09_variables_deep_dive.md#variable-scope).
  - Variable file not imported.

### Environment Variable Not Set

- **Problem**: `Environment variable 'DB_PASSWORD' not found.`
- **Fix**: Set the environment variable before running, or provide a fallback via `--variable`:

```bash
robot --variable DB_PASSWORD:test_password tests/
```

## 7. RF Version Incompatibilities

| Symptom | Likely Cause | Fix |
| ------- | ------------ | --- |
| `RETURN` causes syntax error | Using RF < 5.0 | Upgrade RF or use `[Return]` |
| `TRY/EXCEPT` causes syntax error | Using RF < 5.0 | Upgrade RF |
| `Test Tags` is ignored | Using RF < 6.0 | Upgrade RF or use `Force Tags` |
| `@{list}[index]` deprecation warning | Using old syntax | Change to `${list}[index]` |

Check your version:

```bash
robot --version
```

Upgrade:

```bash
pip install --upgrade robotframework
```

## Debugging Workflow

1. **Open `log.html`**: Find the red (failing) keyword.
2. **Expand the keyword**: Read the exact error message and the arguments passed.
3. **Use TRACE level**: Re-run with `--loglevel TRACE` to see every argument and return value.
4. **Log variables**: Add `Log Variables` to your keyword to dump all in-scope variables.
5. **Log to console**: Add `Log To Console    DEBUG: ${var}` for real-time terminal output.
6. **Dry run**: Use `--dryrun` to catch undefined keyword references before execution.

```robot
*** Keywords ***
Debug Step
    Log Variables                                  # dump all variables to log
    Log To Console    \n--- Current URL: ${URL}    # terminal output
    Capture Page Screenshot                        # screenshot at this point
```

## Community Support

- **Forum**: [forum.robotframework.org](https://forum.robotframework.org)
- **Slack**: [robotframework.slack.com](https://robotframework.slack.com)
- **GitHub Issues**: [github.com/robotframework/robotframework/issues](https://github.com/robotframework/robotframework/issues)
- **SeleniumLibrary Issues**: [github.com/robotframework/SeleniumLibrary/issues](https://github.com/robotframework/SeleniumLibrary/issues)
- **Stack Overflow**: Tag your questions with `robot-framework`
