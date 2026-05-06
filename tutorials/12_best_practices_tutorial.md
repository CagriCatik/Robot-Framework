# Tutorial 12 — Best Practices: Refactoring a Messy Test Suite

## The Scenario

A colleague joined the project last month and wrote the following test file under time pressure. The tests pass. But:

- Locators are hardcoded inline
- Identical browser setup code appears in every test
- One test does three unrelated things and has no meaningful name
- `Sleep` calls paper over timing issues
- There are no tags, so CI has no way to run just the smoke tests

Your job is to refactor this file step by step, applying each best practice with a clear before/after.

## The Starting Point

Save this as `tests/12_messy.robot` so you can compare with the refactored version:

```robot
*** Settings ***
Library    SeleniumLibrary

*** Test Cases ***
test1
    Open Browser    file:///C:/Users/mccat/Desktop/Robot-Framework/simulator/index.html    chrome
    Maximize Browser Window
    Sleep    2s
    Click Button    id:app-icon-climate
    Sleep    1s
    Get Text    id:climate-temperature-value
    Click Button    id:climate-temp-up
    Click Button    id:climate-temp-up
    Click Button    id:climate-temp-up
    Get Text    id:climate-temperature-value
    Close Browser

test2
    Open Browser    file:///C:/Users/mccat/Desktop/Robot-Framework/simulator/index.html    chrome
    Maximize Browser Window
    Sleep    2s
    Click Button    id:app-icon-settings
    Sleep    1s
    Click Button    id:settings-theme-toggle
    Get Element Attribute    id:settings-theme-toggle    data-state
    Click Button    id:settings-wifi-toggle
    Get Element Attribute    id:settings-wifi-toggle    data-state
    Click Button    id:settings-brightness-up
    Get Text    id:settings-brightness-value
    Close Browser

test3
    Open Browser    file:///C:/Users/mccat/Desktop/Robot-Framework/simulator/index.html    chrome
    Maximize Browser Window
    Sleep    2s
    Click Button    id:app-icon-media
    Sleep    1s
    Click Button    id:media-play-pause-button
    Get Element Attribute    id:media-play-pause-button    data-state
    Click Button    id:media-next-button
    Get Text    id:media-track-name
    Close Browser
```

Run it:

```powershell
robot -d results tests/12_messy.robot
```

The tests pass — for now. Notice `Get Text` and `Get Element Attribute` are called but the return values are thrown away. Nothing is actually asserted. These tests would pass even if the application was completely broken.

## Refactoring Step 1 — Replace `Sleep` with Explicit Waits

`Sleep    2s` is a bet that the page is ready within two seconds. On a slow machine or in CI it fails. On a fast machine it wastes two seconds on every run.

```robot
# BEFORE
Sleep    2s
Click Button    id:app-icon-climate

# AFTER
Wait Until Element Is Visible    id:screen-home    timeout=8s
Click Button    id:app-icon-climate
Wait Until Element Is Visible    id:screen-climate    timeout=3s
```

The `Wait Until` version waits as long as needed (up to the timeout) and moves on the instant the condition is met. Faster when the app is fast; patient when it is slow.

## Refactoring Step 2 — Move Setup Into Suite/Test Hooks

Three tests each open and close the browser. That is three full browser launches per run. Move it into Suite Setup/Teardown so the browser opens once:

```robot
*** Settings ***
Library    SeleniumLibrary
Suite Setup      Open Browser    ${SIMULATOR_URL}    ${BROWSER}
Suite Teardown   Close All Browsers
Test Setup       Go To    ${SIMULATOR_URL}
```

Each test now gets a clean page reload via `Test Setup` without the overhead of a new browser process.

## Refactoring Step 3 — Add Real Assertions

Tests that do not assert anything are not tests — they are scripts. Every meaningful state transition needs a verification:

```robot
# BEFORE — no assertion
Click Button    id:climate-temp-up
Get Text    id:climate-temperature-value

# AFTER — the test actually verifies something
${before}=    Get Text    id:climate-temperature-value
Click Button    id:climate-temp-up
${after}=     Get Text    id:climate-temperature-value
Should Not Be Equal    ${before}    ${after}
```

## Refactoring Step 4 — Give Each Test One Job and a Clear Name

`test2` does three unrelated things: theme toggle, Wi-Fi toggle, and brightness. Split it:

```robot
# BEFORE — one test, three concerns, no name
test2
    ... (theme, wifi, brightness mixed together)

# AFTER — three tests, one concern each, descriptive names
Theme Toggle Switches Between Dark And Light Mode
    ...

Wi-Fi Toggle Changes Connection State
    ...

Brightness Increases When Up Button Is Clicked
    ...
```

## Refactoring Step 5 — Centralise Locators in Resource Variables

Hardcoded IDs inside test cases break when the application changes:

```robot
# BEFORE — locator in the test case
Click Button    id:settings-theme-toggle

# AFTER — locator declared once in the resource
${THEME_TOGGLE}    id:settings-theme-toggle
...
Click Button    ${THEME_TOGGLE}
```

## Refactoring Step 6 — Add Tags

```robot
Test Tags    regression    settings
```

And per-test:

```robot
Theme Toggle Switches Between Dark And Light Mode
    [Tags]    smoke    theme
    ...
```

Now CI can run `robot -i smoke tests/` and get the fast critical checks without running the full suite.

## The Refactored Version

Create `tests/12_refactored.robot`:

```robot
*** Settings ***
Documentation    Refactored version of 12_messy.robot.
...              Demonstrates best practices applied to a real simulator test suite.

Library          SeleniumLibrary    timeout=10    run_on_failure=Capture Page Screenshot

Resource         ${CURDIR}/../resources/common.resource
Resource         ${CURDIR}/../resources/climate_page.resource
Resource         ${CURDIR}/../resources/settings_page.resource
Resource         ${CURDIR}/../resources/media_page.resource

Metadata         Refactored    Yes

Suite Setup      Open Simulator
Suite Teardown   Close All Browsers
Test Setup       Go To Home Screen
Test Teardown    Capture Screenshot On Failure

Test Tags        regression

*** Test Cases ***
Temperature Increases When Up Is Clicked Three Times
    [Tags]    smoke    climate
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    ${CLIMATE_SCREEN}    timeout=3s
    ${before}=    Get Driver Temperature
    Click Button    ${TEMP_UP_BTN}
    Click Button    ${TEMP_UP_BTN}
    Click Button    ${TEMP_UP_BTN}
    ${after}=    Get Driver Temperature
    Should Not Be Equal    ${before}    ${after}

Theme Toggle Switches Between Dark And Light Mode
    [Tags]    smoke    settings    theme
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    id:screen-settings    timeout=3s
    ${before}=    Get Element Attribute    ${THEME_TOGGLE}    data-state
    Click Button    ${THEME_TOGGLE}
    ${after}=     Get Element Attribute    ${THEME_TOGGLE}    data-state
    Should Not Be Equal    ${before}    ${after}

Wi-Fi Toggle Changes Connection State
    [Tags]    settings    connectivity
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    id:screen-settings    timeout=3s
    ${before}=    Get Element Attribute    ${WIFI_TOGGLE}    data-state
    Click Button    ${WIFI_TOGGLE}
    ${after}=     Get Element Attribute    ${WIFI_TOGGLE}    data-state
    Should Not Be Equal    ${before}    ${after}
    Click Button    ${WIFI_TOGGLE}    # restore

Brightness Increases When Up Button Is Clicked
    [Tags]    settings
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    id:screen-settings    timeout=3s
    ${before}=    Get Text    ${BRIGHTNESS_VALUE}
    Click Button    ${BRIGHTNESS_UP_BTN}
    ${after}=     Get Text    ${BRIGHTNESS_VALUE}
    Should Not Be Equal    ${before}    ${after}

Play Pause Toggles Media State
    [Tags]    smoke    media
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    ${MEDIA_SCREEN}    timeout=3s
    ${before}=    Get Element Attribute    ${PLAY_PAUSE_BTN}    data-state
    Click Button    ${PLAY_PAUSE_BTN}
    ${after}=     Get Element Attribute    ${PLAY_PAUSE_BTN}    data-state
    Should Not Be Equal    ${before}    ${after}

Next Track Changes Displayed Track Name
    [Tags]    media
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    ${MEDIA_SCREEN}    timeout=3s
    ${before}=    Get Current Track Name
    Click Button    ${NEXT_BTN}
    ${after}=     Get Current Track Name
    Should Not Be Equal    ${before}    ${after}
```

Create `resources/settings_page.resource` if it does not exist yet:

```robot
*** Settings ***
Resource    ${CURDIR}/common.resource

*** Variables ***
${SETTINGS_SCREEN}     id:screen-settings
${THEME_TOGGLE}        id:settings-theme-toggle
${WIFI_TOGGLE}         id:settings-wifi-toggle
${BRIGHTNESS_UP_BTN}   id:settings-brightness-up
${BRIGHTNESS_DOWN_BTN} id:settings-brightness-down
${BRIGHTNESS_VALUE}    id:settings-brightness-value
${LANGUAGE_SELECT}     id:settings-language-select
${UNITS_TOGGLE}        id:settings-units-toggle
${BT_TOGGLE}           id:settings-bluetooth-toggle

*** Keywords ***
Open Settings Screen
    Open Simulator
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    ${SETTINGS_SCREEN}    timeout=3s
```

Run both versions and compare the results:

```powershell
robot -d results/messy   tests/12_messy.robot
robot -d results/clean   tests/12_refactored.robot
```

The messy version is faster to write. The clean version is faster to maintain, debug, and extend. The difference compounds every time a locator changes, a new test is added, or someone has to read the file six months later.

## The Pre-Commit Checklist

Before merging any test file:

- [ ] Test names describe the behaviour being verified, not the steps
- [ ] No `Sleep` — replaced with `Wait Until` keywords
- [ ] No hardcoded locators in test cases — all in resource `*** Variables ***`
- [ ] Every assertion has a `msg=` parameter explaining what failed
- [ ] Tags present: at least `smoke` or `regression` and a feature tag
- [ ] `robot --dryrun` passes
- [ ] `robocop tests/ resources/` reports no errors
- [ ] A real run produces green results

## Practice Challenge

Take `tests/07_cases.robot` (which you wrote in Tutorial 07) and run the pre-commit checklist against it. Apply every item on the checklist that it fails. Run dry run, then full execution, and confirm it is still green after the refactor.
