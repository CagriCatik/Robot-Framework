*** Settings ***
Documentation    Tutorial 10 — User keywords: arguments, defaults, return values, varargs, TRY/EXCEPT.
...              Teaches: [Arguments], RETURN, default args, @{varargs}, &{kwargs}, TRY/EXCEPT,
...              keyword [Teardown], single-responsibility principle.

Library          ${CURDIR}/../libraries/TemperatureUtils.py
Resource         ${CURDIR}/../resources/common.resource

Suite Teardown    Close All Browsers

*** Test Cases ***
Climate Screen Opens And Shows Default Temperature
    [Documentation]    Keyword hides browser setup and navigation — test reads as specification.
    [Tags]    smoke    climate    keywords    tutorial-10
    Open Climate Screen
    Temperature Should Be    22°C

Temperature Increases One Degree Per Click
    [Documentation]    Get Temperature returns a live DOM value; Should Not Be Equal detects the change.
    [Tags]    climate    keywords    tutorial-10
    Open Climate Screen
    ${before}=    Get Temperature
    Click Button    id:climate-temp-up
    ${after}=    Get Temperature
    Should Not Be Equal    ${before}    ${after}
    [Teardown]    Close Browser

Custom Library Validates Temperature Range
    [Documentation]    TemperatureUtils.py parses "22°C" into a float for range checking.
    [Tags]    climate    keywords    custom-lib    tutorial-10
    Open Climate Screen
    ${raw}=    Get Temperature
    ${in_range}=    Temperature Is In Range    ${raw}    16    30
    Should Be True    ${in_range}

All Core Screens Are Reachable Via Varargs Keyword
    [Documentation]    @{varargs} lets one keyword accept any number of screen names.
    [Tags]    navigation    keywords    tutorial-10
    All Screens Should Be Reachable    navigation    media    climate    settings

Seat Heat Cycles Through Three States
    [Documentation]    Cycle Driver Seat Heat returns the new state each call.
    [Tags]    climate    keywords    tutorial-10
    Open Climate Screen
    ${s1}=    Cycle Driver Seat Heat
    Should Be Equal    ${s1}    low
    ${s2}=    Cycle Driver Seat Heat
    Should Be Equal    ${s2}    high
    ${s3}=    Cycle Driver Seat Heat
    Should Be Equal    ${s3}    off
    [Teardown]    Close Browser

Volume Increases By 5 Each Click
    [Documentation]    Get Volume Level returns an integer; diff confirms exact 5-unit step.
    [Tags]    media    keywords    tutorial-10
    Open App Screen    media
    ${before}=    Get Volume Level
    Click Button    id:nav-volume-up
    ${after}=     Get Volume Level
    ${diff}=    Evaluate    ${after} - ${before}
    Should Be Equal As Integers    ${diff}    5
    [Teardown]    Close Browser

TRY EXCEPT Handles Missing Element Gracefully
    [Documentation]    TRY/EXCEPT lets the test continue when an optional element is absent.
    [Tags]    keywords    error-handling    tutorial-10
    Open Simulator
    Click Optional Element    id:this-element-does-not-exist
    Log    Execution continued after optional element was not found.
    [Teardown]    Close Browser

*** Keywords ***
Open Climate Screen
    [Documentation]    Opens the browser, maximises, waits for home, then goes to climate.
    Open Simulator
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s

Open App Screen
    [Documentation]    Generic opener — navigates to any app by name.
    [Arguments]    ${app}    ${browser}=${BROWSER}    ${maximise}=${TRUE}
    Open Browser    ${SIMULATOR_URL}    ${browser}
    Run Keyword If    ${maximise}    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=8s
    Click Button    id:app-icon-${app}
    Wait Until Element Is Visible    id:screen-${app}    timeout=3s

Get Temperature
    [Documentation]    Returns the current driver temperature string (e.g. "22°C").
    ${value}=    Get Text    id:climate-temperature-value
    RETURN    ${value}

Temperature Should Be
    [Documentation]    Asserts the driver temperature display matches expected.
    [Arguments]    ${expected}
    ${actual}=    Get Temperature
    Should Be Equal    ${actual}    ${expected}
    ...    msg=Driver temp: expected ${expected}, got ${actual}

Cycle Driver Seat Heat
    [Documentation]    Clicks the driver seat heat button once. Returns new state (off/low/high).
    Click Button    id:climate-driver-seat-heat
    ${state}=    Get Element Attribute    id:climate-driver-seat-heat    data-state
    RETURN    ${state}

Get Volume Level
    [Documentation]    Returns the volume as an integer.
    ${raw}=    Get Text    id:nav-volume-value
    ${vol}=    Convert To Integer    ${raw}
    RETURN    ${vol}

All Screens Should Be Reachable
    [Documentation]    Visits each app screen in the list and returns home after each.
    [Arguments]    @{app_names}
    Open Simulator
    FOR    ${app}    IN    @{app_names}
        Click Button    id:app-icon-${app}
        Wait Until Element Is Visible    id:screen-${app}    timeout=3s
        Go To Home Screen
    END
    [Teardown]    Close Browser

Click Optional Element
    [Documentation]    Clicks locator if present; logs a warning and continues if absent.
    [Arguments]    ${locator}
    TRY
        Wait Until Element Is Visible    ${locator}    timeout=2s
        Click Element    ${locator}
    EXCEPT    *    type=glob
        Log    Optional element '${locator}' not found — skipping.    WARN
    END
