# Tutorial 09 — Variables Deep Dive

## The Scenario

Your tests are working, but the simulator URL is hardcoded in six different files. The climate locators appear in three files. When the team moves from local testing to a hosted staging server, you have to edit everything. This tutorial shows how to centralise all values using the right variable type for each situation.

## The Three Variable Sigils

```robot
${scalar}    one value  — string, number, boolean, object, return value
@{list}      ordered collection  — loop over it, index into it
&{dict}      key-value pairs  — access by name
```

The sigil (`$`, `@`, `&`) tells Robot Framework how to *use* the variable, not just what it is. You can iterate a `${list}` variable in a FOR loop; you can access a `&{user}` value like `${user}[username]`.

## Part 1 — Scalars in Action

Scalars are the most common. Any single value — including return values from keywords — is a scalar.

Create `tests/09_variables.robot`:

```robot
*** Settings ***
Library      SeleniumLibrary
Resource     ${CURDIR}/../resources/common.resource
Suite Setup      Open Browser    ${SIMULATOR_URL}    ${BROWSER}
Suite Teardown   Close All Browsers

*** Variables ***
# These are file-scope constants. Use UPPER_CASE for globals.
${CLIMATE_SCREEN}         id:screen-climate
${CLIMATE_TEMP_DISPLAY}   id:climate-temperature-value
${CLIMATE_TEMP_UP}        id:climate-temp-up
${CLIMATE_TEMP_DOWN}      id:climate-temp-down
${MIN_TEMP}               16
${MAX_TEMP}               30

*** Test Cases ***
Scalar Variables Replace Hardcoded Values
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    ${CLIMATE_SCREEN}    timeout=3s

    # Return value stored as scalar
    ${current_temp}=    Get Text    ${CLIMATE_TEMP_DISPLAY}
    Log    Current temperature: ${current_temp}

    # Inline arithmetic with Evaluate
    ${num}=    Evaluate    float("${current_temp}".replace("°C",""))
    Should Be True    ${MIN_TEMP} <= ${num} <= ${MAX_TEMP}
```

Every locator is a variable. When the ID changes (it will), you update one line.

## Part 2 — Lists for Iteration

A list variable lets you iterate over a collection of values without repeating test steps.

Add to `tests/09_variables.robot`:

```robot
*** Variables ***
@{ALL_APP_SCREENS}    navigation    media    climate    phone    vehicle    settings    camera    weather

*** Test Cases ***
Every App Screen Is Reachable
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s

    FOR    ${app}    IN    @{ALL_APP_SCREENS}
        Click Button    id:app-icon-${app}
        Wait Until Element Is Visible    id:screen-${app}    timeout=3s
        Element Text Should Be    id:nav-current-screen    ${app.upper()}
        Click Button    id:nav-home-button
        Wait Until Element Is Visible    id:screen-home    timeout=2s
    END
```

Notice `id:app-icon-${app}` — the variable interpolates directly into the locator string. This is how you drive eight tests from a single loop without duplicating code.

Accessing list items by index:

```robot
*** Test Cases ***
Access List Items By Index
    ${first_app}=    Set Variable    ${ALL_APP_SCREENS}[0]
    ${last_app}=     Set Variable    ${ALL_APP_SCREENS}[-1]
    Should Be Equal    ${first_app}    navigation
    Should Be Equal    ${last_app}     weather
```

> **Never use** `@{ALL_APP_SCREENS}[0]` to access a single item — that syntax is deprecated. Always use `${list}[index]`.

## Part 3 — Dictionaries for Structured Data

Dictionaries group related values together. Use them for user credentials, configuration blocks, and expected results.

```robot
*** Variables ***
&{DARK_THEME_STATE}     button_text=Dark Mode    data_state=dark    html_theme=dark
&{LIGHT_THEME_STATE}    button_text=Light Mode   data_state=light   html_theme=light

*** Test Cases ***
Theme Toggle Produces Expected State
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    id:screen-settings    timeout=3s

    # Verify dark theme is the default
    Element Text Should Be
    ...    id:settings-theme-toggle
    ...    ${DARK_THEME_STATE}[button_text]
    ${data_state}=    Get Element Attribute    id:settings-theme-toggle    data-state
    Should Be Equal    ${data_state}    ${DARK_THEME_STATE}[data_state]

    # Toggle to light
    Click Button    id:settings-theme-toggle
    Element Text Should Be    id:settings-theme-toggle    ${LIGHT_THEME_STATE}[button_text]
```

Accessing dictionary values: `${DARK_THEME_STATE}[button_text]` — always scalar syntax, never `&{}[key]`.

## Part 4 — Built-In Variables You Should Know

These exist without any declaration. Open `log.html` after the next run to see their actual values.

```robot
*** Test Cases ***
Inspect Built In Variables
    Log    File location:    ${CURDIR}
    Log    Invocation dir:   ${EXECDIR}
    Log    Test name:        ${TEST NAME}
    Log    Suite name:       ${SUITE NAME}
    Log    Temp dir:         ${TEMPDIR}
    Log    Empty string:     "${EMPTY}"
    Log    True boolean:     ${TRUE}
    Log    False boolean:    ${FALSE}
    Should Be True    ${TRUE}
    Should Not Be True    ${FALSE}
    Should Be Equal    ${EMPTY}    ${EMPTY}
```

`${TEST STATUS}` and `${TEST MESSAGE}` are only available inside `Test Teardown` — that is where they are useful for conditional screenshot logic:

```robot
Test Teardown
    Run Keyword If    '${TEST STATUS}' == 'FAIL'
    ...    Log    Test failed: ${TEST MESSAGE}    WARN
```

## Part 5 — Environment Variables

Use `%{VARNAME}` to read OS environment variables. If the variable is not set, the test fails with a clear message:

```powershell
# Set before running
$env:CI_BROWSER = "firefox"
```

```robot
*** Variables ***
${BROWSER}    %{CI_BROWSER}    # fails if not set

*** Test Cases ***
Browser Comes From Environment
    Log    Running with browser: ${BROWSER}
```

To provide a fallback when the environment variable might not exist, override it from the command line:

```powershell
robot -d results -v BROWSER:chrome tests/09_variables.robot
```

Command-line `-v` values take precedence over `*** Variables ***` section values and variable file values.

## Part 6 — External Variable Files

When tests need different values for different environments, store them in Python files.

Create `data/local.py`:

```python
SIMULATOR_URL = "file:///C:/Users/mccat/Desktop/Robot-Framework/simulator/index.html"
BROWSER       = "chrome"
TIMEOUT       = 8
```

Create `data/headless.py`:

```python
SIMULATOR_URL = "file:///C:/Users/mccat/Desktop/Robot-Framework/simulator/index.html"
BROWSER       = "headless chrome"
TIMEOUT       = 15
```

Import in a suite:

```robot
*** Settings ***
Variables    ${CURDIR}/../data/local.py
```

Switch at the command line without touching the suite:

```powershell
# Local with Chrome GUI
robot -d results --variablefile data/local.py tests/

# Headless for CI
robot -d results --variablefile data/headless.py tests/
```

Variable files can also define complex structures:

```python
# data/users.py
ADMIN_USER = {"username": "admin", "role": "admin"}
TEST_USERS = [
    {"username": "alice", "role": "viewer"},
    {"username": "bob",   "role": "editor"},
]
```

```robot
*** Settings ***
Variables    ${CURDIR}/../data/users.py

*** Test Cases ***
Admin User Has Correct Role
    Should Be Equal    ${ADMIN_USER}[role]    admin

All Test Users Have Usernames
    FOR    ${user}    IN    @{TEST_USERS}
        Should Not Be Empty    ${user}[username]
    END
```

## Variable Scope Cheat-Sheet

| Scope | Set with | Visible to |
| --- | --- | --- |
| Local | `${x}=    keyword` or `[Arguments]` | Current keyword only |
| Test | `Set Test Variable    ${x}    value` | All keywords in the current test |
| Suite | `Set Suite Variable    ${x}    value` | All tests in the current file |
| Global | `Set Global Variable    ${x}    value` | All suites in the run (use rarely) |

Prefer the smallest scope that works. Global variables shared between suites make test order matter — a recipe for flaky tests.

## Practice Challenge

Create `data/climate_config.py` with:

```python
DEFAULT_DRIVER_TEMP   = "22°C"
DEFAULT_FAN_SPEED     = "2"
MIN_TEMP              = 16
MAX_TEMP              = 30
SEAT_HEAT_STATES      = ["off", "low", "high"]
```

Write a test that:

1. Imports the variable file
2. Opens the climate screen
3. Asserts `id:climate-temperature-value` matches `${DEFAULT_DRIVER_TEMP}`
4. Asserts `id:climate-fan-speed-value` matches `${DEFAULT_FAN_SPEED}`
5. Iterates over `${SEAT_HEAT_STATES}` and clicks the seat heat button, asserting `data-state` matches each expected cycle value in order
