# Tutorial 06 — The Settings Section

## The Scenario

Your climate tests work. Now you need to add settings tests and media tests. You realise that every suite repeats the same browser setup and the same `Test Teardown` screenshot logic. The Settings section is where you solve that — you declare what a suite needs once, and every test inherits it.

## What the Settings Section Controls

```robot
*** Settings ***
Library        which tools can this suite use?
Resource       which shared keywords and variables does it import?
Variables      which external data file does it load?
Documentation  what does this suite do? (appears in report.html)
Metadata       what extra labels should appear in the report?
Suite Setup    what runs once before the first test?
Suite Teardown what runs once after the last test?
Test Setup     what runs before every test?
Test Teardown  what runs after every test (even after failure)?
Test Tags      which tags apply to every test in this file?
Test Timeout   how long may a single test run before it is killed?
Test Template  which keyword does every test case body use as data?
```

## Exercise 1 — A Real Suite Settings Block

Create `tests/06_settings_demo.robot`:

```robot
*** Settings ***
Documentation     Settings section tutorial — tests the simulator Settings screen.
...               Covers theme toggle, brightness controls, and Wi-Fi toggle.

Library           SeleniumLibrary    timeout=10    run_on_failure=Capture Page Screenshot

Resource          ${CURDIR}/../resources/common.resource

Metadata          Feature       Settings Screen
Metadata          Ticket        SIM-042
Metadata          Environment   local

Suite Setup       Open Browser And Navigate To Settings
Suite Teardown    Close All Browsers

Test Setup        Settings Screen Should Be Active
Test Teardown     Return To Home Screen

Test Tags         settings    regression
Test Timeout      1 minute

*** Variables ***
${SETTINGS_SCREEN}    id:screen-settings

*** Test Cases ***
Theme Toggles Between Dark And Light
    [Tags]    smoke    theme
    ${state_before}=    Get Element Attribute    id:settings-theme-toggle    data-state
    Click Button    id:settings-theme-toggle
    ${state_after}=    Get Element Attribute    id:settings-theme-toggle    data-state
    Should Not Be Equal    ${state_before}    ${state_after}

Brightness Can Be Increased
    ${before}=    Get Text    id:settings-brightness-value
    Click Button    id:settings-brightness-up
    ${after}=     Get Text    id:settings-brightness-value
    Should Not Be Equal    ${before}    ${after}

Wi-Fi Toggle Changes State
    [Tags]    connectivity
    ${initial}=    Get Element Attribute    id:settings-wifi-toggle    data-state
    Click Button    id:settings-wifi-toggle
    ${toggled}=    Get Element Attribute    id:settings-wifi-toggle    data-state
    Should Not Be Equal    ${initial}    ${toggled}
    # Restore original state
    Click Button    id:settings-wifi-toggle

*** Keywords ***
Open Browser And Navigate To Settings
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=8s
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    ${SETTINGS_SCREEN}    timeout=3s

Settings Screen Should Be Active
    Element Should Be Visible    ${SETTINGS_SCREEN}

Return To Home Screen
    Click Button    id:nav-home-button
    Wait Until Element Is Visible    id:screen-home    timeout=3s
```

Run:

```powershell
robot -d results tests/06_settings_demo.robot
```

Open `report.html`. Find the metadata block — `Feature: Settings Screen` and `Ticket: SIM-042` appear there. Every test shows the `settings` and `regression` tags automatically from `Test Tags`.

## Exercise 2 — Library Constructor Arguments

SeleniumLibrary accepts constructor arguments that change its behaviour globally for the suite:

```robot
Library    SeleniumLibrary    timeout=10    run_on_failure=Capture Page Screenshot
```

- `timeout=10` — default wait time for all `Wait Until …` keywords
- `run_on_failure=Capture Page Screenshot` — automatically saves a screenshot whenever **any** keyword in the library fails

This replaces the manual `Test Teardown` screenshot pattern for SeleniumLibrary failures specifically. The screenshot is saved into the `results/` folder and linked in `log.html`.

## Exercise 3 — Variables File Import

When different environments (local, staging, CI) need different values, store them in a Python file and import it with `Variables`:

Create `data/local_config.py`:

```python
SIMULATOR_URL = "file:///C:/Users/mccat/Desktop/Robot-Framework/simulator/index.html"
BROWSER       = "chrome"
TIMEOUT       = 10
```

Create `data/ci_config.py`:

```python
SIMULATOR_URL = "file:///home/runner/work/Robot-Framework/simulator/index.html"
BROWSER       = "chrome"
TIMEOUT       = 15
```

Use in a suite:

```robot
*** Settings ***
Variables    ${CURDIR}/../data/local_config.py
```

Switch environments at the command line without touching any test file:

```powershell
robot --variablefile data/ci_config.py tests/06_settings_demo.robot
```

## Exercise 4 — The Difference Between Suite Setup and Test Setup

Run the settings suite and look at `log.html`. Expand the suite node at the top:

- **Suite Setup** (`Open Browser And Navigate To Settings`) runs **once** — you see it before the first test
- **Test Setup** (`Settings Screen Should Be Active`) runs **three times** — once before each test
- **Test Teardown** (`Return To Home Screen`) runs **three times** — once after each test, even if the test failed

This is why expensive operations (opening a browser, creating a database connection, seeding test data) belong in Suite Setup — not Test Setup. Doing them per-test multiplies the cost by the number of tests.

## Common Mistakes in the Settings Section

### 1. Putting complex logic directly in a hook setting

Wrong:

```robot
Suite Setup    Open Browser    ${URL}    chrome    options=add_argument("--headless")
```

Right — wrap it in a named keyword:

```robot
Suite Setup    Open Browser In Headless Mode

*** Keywords ***
Open Browser In Headless Mode
    ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    modules=sys
    Call Method    ${options}    add_argument    --headless
    Create Webdriver    Chrome    options=${options}
    Go To    ${SIMULATOR_URL}
```

### 2. Using `Force Tags` instead of `Test Tags` in new suites

`Force Tags` is deprecated in Robot Framework 6. Use `Test Tags` for any new suite.

### 3. Relative resource paths

Wrong — breaks if `robot` is run from a subdirectory:

```robot
Resource    resources/common.resource
```

Right — always works:

```robot
Resource    ${CURDIR}/../resources/common.resource
```

## Practice Challenge

Add a fourth test to `tests/06_settings_demo.robot` that:

1. Selects `Deutsch` from `id:settings-language-select`
2. Verifies the selection was accepted using `Get Selected List Value`
3. Resets the selection back to `en`

Then add `Metadata    Author    <your name>` to the Settings section and check that it appears in `report.html`.
