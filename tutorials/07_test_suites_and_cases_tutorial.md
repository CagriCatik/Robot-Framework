# Tutorial 07 — Test Suites, Cases, Tags, and Data-Driven Tests

## The Scenario

You now have climate tests, settings tests, and media tests scattered across multiple files. A new team member asks: "How do I run only the smoke tests? How do I skip the tests that are still broken?" This tutorial shows how to organise suites into folders, use tags for execution strategy, and write data-driven tests for validation rules that repeat across many inputs.

## Part 1 — Test Case Settings

Every test case can carry its own settings written as `[Bracketed]` lines inside the test body, before the keyword calls.

Create `tests/07_cases.robot`:

```robot
*** Settings ***
Library      SeleniumLibrary
Resource     ${CURDIR}/../resources/common.resource
Suite Setup      Open Browser    ${SIMULATOR_URL}    ${BROWSER}
Suite Teardown   Close All Browsers
Test Setup       Go To    ${SIMULATOR_URL}

*** Test Cases ***
Climate Screen Is Reachable
    [Documentation]    Smoke check — climate icon navigates to climate screen.
    [Tags]             smoke    climate    priority:high
    [Setup]            Wait Until Element Is Visible    id:screen-home    timeout=5s
    [Teardown]         Click Button    id:nav-home-button
    [Timeout]          30 seconds
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    Element Text Should Be    id:nav-current-screen    CLIMATE

Media Screen Shows Track Name
    [Documentation]    The media screen must display a non-empty track name on load.
    [Tags]             smoke    media
    [Teardown]         Click Button    id:nav-home-button
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    id:screen-media    timeout=3s
    ${track}=    Get Text    id:media-track-name
    Should Not Be Empty    ${track}

Volume Controls Are Functional
    [Tags]    media    regression
    [Teardown]         Click Button    id:nav-home-button
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    id:screen-media    timeout=3s
    ${before}=    Get Text    id:media-volume-value
    Click Button    id:media-volume-up
    ${after}=     Get Text    id:media-volume-value
    Should Not Be Equal    ${before}    ${after}

Settings Theme Feature Is Working
    [Tags]    settings    regression    WIP
    [Documentation]    Theme toggle — still verifying behaviour after redesign.
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    id:screen-settings    timeout=3s
    Click Button    id:settings-theme-toggle
    ${state}=    Get Element Attribute    id:settings-theme-toggle    data-state
    Should Be Equal    ${state}    light
```

Run all:

```powershell
robot -d results tests/07_cases.robot
```

Run only smoke tests:

```powershell
robot -d results -i smoke tests/07_cases.robot
```

Exclude work-in-progress:

```powershell
robot -d results -e WIP tests/07_cases.robot
```

Run smoke but not WIP:

```powershell
robot -d results -i smoke -e WIP tests/07_cases.robot
```

Open `report.html` after each run and compare the statistics. Notice the WIP test is excluded from the last two runs without being deleted from the file.

## Part 2 — Organising Into a Folder Suite

A folder becomes a suite when it contains `.robot` files. Create this layout:

```text
tests/
├── __init__.robot
├── climate/
│   ├── __init__.robot
│   └── temperature_tests.robot
├── media/
│   ├── __init__.robot
│   └── playback_tests.robot
└── settings/
    ├── __init__.robot
    └── theme_tests.robot
```

Create `tests/climate/temperature_tests.robot`:

```robot
*** Settings ***
Library      SeleniumLibrary
Resource     ${CURDIR}/../../resources/common.resource
Suite Setup      Open Browser    ${SIMULATOR_URL}    ${BROWSER}
Suite Teardown   Close All Browsers
Test Setup       Open Climate Screen
Test Teardown    Run Keywords
...    Click Button    id:nav-home-button
...    AND    Run Keyword If Test Failed    Capture Page Screenshot
Test Tags    climate

*** Test Cases ***
Driver Temperature Starts At 22
    Element Text Should Be    id:climate-temperature-value    22°C

Temperature Increases By One Per Click
    ${before}=    Get Text    id:climate-temperature-value
    Click Button    id:climate-temp-up
    ${after}=     Get Text    id:climate-temperature-value
    Should Not Be Equal    ${before}    ${after}

Temperature Cannot Exceed 30 Degrees
    FOR    ${i}    IN RANGE    20
        Click Button    id:climate-temp-up
    END
    Element Text Should Be    id:climate-temperature-value    30°C

Temperature Cannot Drop Below 16 Degrees
    FOR    ${i}    IN RANGE    20
        Click Button    id:climate-temp-down
    END
    Element Text Should Be    id:climate-temperature-value    16°C

*** Keywords ***
Open Climate Screen
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
```

Create `tests/media/playback_tests.robot`:

```robot
*** Settings ***
Library      SeleniumLibrary
Resource     ${CURDIR}/../../resources/common.resource
Suite Setup      Open Browser    ${SIMULATOR_URL}    ${BROWSER}
Suite Teardown   Close All Browsers
Test Setup       Open Media Screen
Test Teardown    Run Keyword If Test Failed    Capture Page Screenshot
Test Tags    media

*** Test Cases ***
Play Pause Toggles State Attribute
    ${initial}=    Get Element Attribute    id:media-play-pause-button    data-state
    Click Button    id:media-play-pause-button
    ${toggled}=    Get Element Attribute    id:media-play-pause-button    data-state
    Should Not Be Equal    ${initial}    ${toggled}

Next Track Changes Track Name
    ${before}=    Get Text    id:media-track-name
    Click Button    id:media-next-button
    ${after}=     Get Text    id:media-track-name
    Should Not Be Equal    ${before}    ${after}

Source Tab Becomes Active On Click
    Click Button    id:media-source-bluetooth
    Element Should Be Visible    css:#media-source-bluetooth.active

*** Keywords ***
Open Media Screen
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    id:screen-media    timeout=3s
```

Run the whole tree:

```powershell
robot -d results tests/
```

Run only climate:

```powershell
robot -d results --suite climate tests/
```

Run only media smoke tests:

```powershell
robot -d results -i smoke --suite media tests/
```

Open `log.html`. The suite hierarchy mirrors the folder structure — you can fold and unfold entire feature areas.

## Part 3 — Data-Driven Tests with Templates

The climate temperature has a hard boundary: minimum 16°C, maximum 30°C. Testing boundary behaviour with duplicated test cases is tedious:

```robot
# DON'T DO THIS — same logic, different data, three times
Temperature 15 Is Below Minimum
    ...

Temperature 16 Is The Minimum
    ...

Temperature 30 Is The Maximum
    ...
```

Use a template instead. Create `tests/climate/boundary_tests.robot`:

```robot
*** Settings ***
Library      SeleniumLibrary
Resource     ${CURDIR}/../../resources/common.resource
Suite Setup      Open Browser    ${SIMULATOR_URL}    ${BROWSER}
Suite Teardown   Close All Browsers
Test Tags    climate    boundary

# All test cases in this file use the same template keyword
Test Template    Verify Temperature Boundary

*** Test Cases ***    CLICKS_UP    CLICKS_DOWN    EXPECTED_TEMP
At Maximum After 20 Up Clicks     20    0    30°C
At Minimum After 20 Down Clicks    0    20    16°C
Middle Value After Mixed Clicks    5     3    24°C

*** Keywords ***
Verify Temperature Boundary
    [Arguments]    ${clicks_up}    ${clicks_down}    ${expected_temp}
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    FOR    ${i}    IN RANGE    ${clicks_up}
        Click Button    id:climate-temp-up
    END
    FOR    ${i}    IN RANGE    ${clicks_down}
        Click Button    id:climate-temp-down
    END
    Element Text Should Be    id:climate-temperature-value    ${expected_temp}
```

Run:

```powershell
robot -d results tests/climate/boundary_tests.robot
```

Three test cases run, each with different data, all using the same verification logic. Adding a new boundary scenario is one line of data — no copy-pasting.

## Tag Strategy for a Real Project

| Tag | What it selects | When to run |
| --- | --- | --- |
| `smoke` | Critical path, fast | Every commit |
| `regression` | Full feature coverage | Nightly or before release |
| `climate` / `media` / `settings` | Feature area | When working in that area |
| `boundary` | Edge case validation | Before release |
| `WIP` | Incomplete / broken tests | Excluded from all CI runs |
| `priority:high` | Must-pass before merge | PR checks |

```powershell
# PR check — only high priority, no WIP
robot -d results -i priority:high -e WIP tests/

# Nightly — everything except WIP and slow tests
robot -d results -e WIP -e slow tests/

# Feature work — only climate, including WIP
robot -d results -i climate tests/
```

## Practice Challenge

Add a data-driven template test for fan speed:

- The fan speed range is 0–7
- Create a `*** Test Cases ***` table with at least five rows: clicking up `N` times from the default value of `2` should land at the clamped result
- Include boundary rows for exceeding 7 and going below 0

Run with `robot -i boundary tests/climate/` and verify all rows pass.
