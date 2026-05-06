# Tutorial 10 — User-Defined Keywords

## The Scenario

You look at a test case and see twelve lines of SeleniumLibrary calls. Someone has to understand all twelve to know what the test is doing. A new team member spends 20 minutes staring at it before asking "so… what is this test actually checking?" Keywords fix that. By the end of this tutorial, the same behaviour fits in three lines and reads like a specification.

## The Problem This Solves

Before keywords:

```robot
*** Test Cases ***
Climate Temperature Can Be Raised To Maximum
    Open Browser    file:///${EXECDIR}/simulator/index.html    chrome
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=8s
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    FOR    ${i}    IN RANGE    20
        Click Button    id:climate-temp-up
    END
    ${value}=    Get Text    id:climate-temperature-value
    Should Be Equal    ${value}    30°C
    Click Button    id:nav-home-button
    Close Browser
```

After keywords:

```robot
*** Test Cases ***
Climate Temperature Can Be Raised To Maximum
    Open Climate Screen
    Raise Temperature To Maximum
    Temperature Should Be    30°C
    [Teardown]    Close Browser
```

The second version tells you **what** is being tested. The first forces you to figure it out from implementation details.

## Part 1 — Creating Your First Keywords

Create `tests/10_keywords.robot`:

```robot
*** Settings ***
Library    SeleniumLibrary
Resource   ${CURDIR}/../resources/common.resource
Suite Teardown    Close All Browsers

*** Test Cases ***
Climate Screen Opens And Shows Default Temperature
    Open Climate Screen
    Temperature Should Be    22°C

Temperature Increases One Degree Per Click
    Open Climate Screen
    ${before}=    Get Temperature
    Click Button    id:climate-temp-up
    ${after}=    Get Temperature
    Should Not Be Equal    ${before}    ${after}

Fan Speed Increases And Resets
    Open Climate Screen
    Raise Fan Speed    3
    Fan Speed Should Be    5
    [Teardown]    Close Browser

*** Keywords ***
Open Climate Screen
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=8s
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s

Get Temperature
    [Documentation]    Returns the current driver temperature as displayed (e.g. "22°C").
    ${value}=    Get Text    id:climate-temperature-value
    RETURN    ${value}

Temperature Should Be
    [Arguments]    ${expected}
    [Documentation]    Asserts the driver temperature display matches expected value.
    ${actual}=    Get Temperature
    Should Be Equal    ${actual}    ${expected}
    ...    msg=Expected temperature ${expected} but display shows ${actual}

Raise Fan Speed
    [Arguments]    ${clicks}
    FOR    ${i}    IN RANGE    ${clicks}
        Click Button    id:climate-fan-up
    END

Fan Speed Should Be
    [Arguments]    ${expected}
    ${actual}=    Get Text    id:climate-fan-speed-value
    Should Be Equal    ${actual}    ${expected}
    ...    msg=Expected fan speed ${expected} but display shows ${actual}
```

Run:

```powershell
robot -d results tests/10_keywords.robot
```

In `log.html`, each keyword call expands to show its inner steps. The test body stays at the business level while the log gives full technical detail when needed.

## Part 2 — Default Arguments

Arguments with defaults make keywords flexible without requiring callers to specify every option.

Add to `tests/10_keywords.robot`:

```robot
*** Keywords ***
Open App Screen
    [Arguments]    ${app}    ${browser}=${BROWSER}    ${maximise}=${TRUE}
    [Documentation]    Opens the browser and navigates to the given app screen.
    ...                Browser and maximise default to the suite-level settings.
    Open Browser    ${SIMULATOR_URL}    ${browser}
    Run Keyword If    ${maximise}    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=8s
    Click Button    id:app-icon-${app}
    Wait Until Element Is Visible    id:screen-${app}    timeout=3s
```

Callers:

```robot
*** Test Cases ***
Media Screen Opens With Defaults
    Open App Screen    media
    [Teardown]    Close Browser

Settings Opens In Firefox Without Maximise
    Open App Screen    settings    browser=firefox    maximise=${FALSE}
    [Teardown]    Close Browser
```

## Part 3 — Variable-Length Arguments (`@{varargs}`)

When the number of inputs is not known at design time, collect them into a list:

```robot
*** Keywords ***
All Screens Should Be Reachable
    [Arguments]    @{app_names}
    [Documentation]    Visits each app screen in the given list and returns to home.
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=8s
    FOR    ${app}    IN    @{app_names}
        Click Button    id:app-icon-${app}
        Wait Until Element Is Visible    id:screen-${app}    timeout=3s
        Click Button    id:nav-home-button
        Wait Until Element Is Visible    id:screen-home    timeout=2s
    END
    [Teardown]    Close Browser

*** Test Cases ***
Core Navigation Screens Work
    All Screens Should Be Reachable    navigation    media    climate    settings
```

## Part 4 — Keywords That Return Values

Keywords that discover information should return it. Callers decide what to do with it — assert, log, store, pass on.

```robot
*** Keywords ***
Get Seat Heat State
    [Arguments]    ${zone}=driver
    [Documentation]    Returns the seat heat state (off/low/high) for the given zone.
    ${element_id}=    Set Variable    id:climate-${zone}-seat-heat
    ${state}=    Get Element Attribute    ${element_id}    data-state
    RETURN    ${state}

Get Volume Level
    [Documentation]    Returns the current volume as an integer.
    ${raw}=    Get Text    id:nav-volume-value
    ${volume}=    Convert To Integer    ${raw}
    RETURN    ${volume}

*** Test Cases ***
Seat Heat Cycles Through Three States
    Open Climate Screen
    ${state1}=    Get Seat Heat State
    Should Be Equal    ${state1}    off
    Click Button    id:climate-driver-seat-heat
    ${state2}=    Get Seat Heat State
    Should Be Equal    ${state2}    low
    Click Button    id:climate-driver-seat-heat
    ${state3}=    Get Seat Heat State
    Should Be Equal    ${state3}    high
    [Teardown]    Close Browser

Volume Increases By 5 Each Click
    Open App Screen    media
    ${before}=    Get Volume Level
    Click Button    id:nav-volume-up
    ${after}=     Get Volume Level
    ${diff}=    Evaluate    ${after} - ${before}
    Should Be Equal As Integers    ${diff}    5
    [Teardown]    Close Browser
```

## Part 5 — Error Handling with `TRY / EXCEPT`

Use `TRY/EXCEPT` only for genuinely recoverable situations — an optional element that may or may not be present, a flaky network call, a known intermittent condition. Never use it to hide real product defects.

```robot
*** Keywords ***
Dismiss Cookie Banner If Present
    [Documentation]    Clicks the dismiss button if a cookie banner appears.
    ...                Does not fail if the banner is absent.
    TRY
        Wait Until Element Is Visible    id:cookie-dismiss    timeout=2s
        Click Button    id:cookie-dismiss
        Log    Cookie banner dismissed.
    EXCEPT    *    type=glob
        Log    No cookie banner present.
    END

Click Button With Retry
    [Arguments]    ${locator}    ${retries}=3
    [Documentation]    Retries a click up to ${retries} times before failing.
    FOR    ${attempt}    IN RANGE    ${retries}
        TRY
            Click Button    ${locator}
            RETURN
        EXCEPT
            Log    Click attempt ${attempt + 1} failed. Retrying...    WARN
        END
    END
    Fail    Could not click ${locator} after ${retries} attempts.
```

## Part 6 — Keyword Teardown

A keyword can clean up after itself even if its body fails. This is useful when a keyword allocates a resource:

```robot
*** Keywords ***
Run Climate Test With Screenshot
    [Teardown]    Capture Page Screenshot
    [Documentation]    Always captures a screenshot at the end of this keyword.
    Open Climate Screen
    Raise Temperature To Maximum
    Temperature Should Be    30°C
```

The `[Teardown]` in a keyword runs after the keyword body completes — whether it passed or failed. This is independent of the test's `[Teardown]`.

## What Makes a Good Keyword

| Quality | What it looks like |
| --- | --- |
| Single responsibility | Does exactly one thing at the right level of abstraction |
| Named by intent | `Temperature Should Be` not `Check Climate Value Text` |
| Hides implementation | Caller does not need to know locator IDs |
| Returns meaningful values | `Get Temperature` returns `"22°C"`, not the WebElement |
| Arguments with defaults | Works simply by default, customisable when needed |
| Documented | `[Documentation]` explains the WHY, not the what |

## Practice Challenge

Write these keywords and test them:

1. `Set Fan Speed To    ${target}` — clicks fan up or down until the display shows `${target}`, failing if it cannot reach it within 10 clicks
2. `Toggle AC And Return State` — clicks the AC toggle and returns `"on"` or `"off"` based on the new `data-state`
3. `Restore Climate Defaults` — resets driver temperature to 22°C and fan speed to 2 (useful as a `Test Teardown`)

Write a test that calls all three and asserts the final state.
