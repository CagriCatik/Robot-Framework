*** Settings ***
Documentation    Tutorial 09 — Scalars, lists, dicts, built-ins, env vars, external variable files.
...              Teaches: all variable types, scope, iteration, interpolation in locators.

Library          Collections
Resource         ${CURDIR}/../resources/common.resource
Variables        ${CURDIR}/../data/climate_config.py

Suite Setup      Open Simulator
Suite Teardown   Close All Browsers
Test Setup       Go To Home Screen

*** Variables ***
# Locator variables — if an ID changes, update only here
${CLIMATE_SCREEN}           id:screen-climate
${CLIMATE_TEMP_DISPLAY}     id:climate-temperature-value
${CLIMATE_FAN_DISPLAY}      id:climate-fan-speed-value

# Ordered list of all app names — used for iteration
@{ALL_APP_SCREENS}    navigation    media    climate    phone    vehicle    settings    camera    weather

# Dictionary — groups related values
&{DARK_THEME_STATE}     button_text=Dark Mode    data_state=dark
&{LIGHT_THEME_STATE}    button_text=Light Mode   data_state=light

*** Test Cases ***
Scalar Locator Variables Replace Hardcoded IDs
    [Documentation]    Locators stored as variables — one change point for each ID.
    [Tags]    variables    climate    tutorial-09
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    ${CLIMATE_SCREEN}    timeout=3s
    ${temp}=    Get Text    ${CLIMATE_TEMP_DISPLAY}
    Log    Current temperature: ${temp}
    Should Not Be Empty    ${temp}

External Variable File Provides Climate Defaults
    [Documentation]    Variables loaded from data/climate_config.py — no hardcoding.
    [Tags]    variables    climate    tutorial-09
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    ${CLIMATE_SCREEN}    timeout=3s
    Element Text Should Be    ${CLIMATE_TEMP_DISPLAY}    ${DEFAULT_DRIVER_TEMP}
    Element Text Should Be    ${CLIMATE_FAN_DISPLAY}     ${DEFAULT_FAN_SPEED}

Every App Screen Is Reachable Via List Iteration
    [Documentation]    @{ALL_APP_SCREENS} drives the loop — no test duplication per screen.
    ...                Interpolates the variable into locator IDs: id:app-icon-${app}
    [Tags]    variables    navigation    smoke    tutorial-09
    FOR    ${app}    IN    @{ALL_APP_SCREENS}
        Click Button    id:app-icon-${app}
        Wait Until Element Is Visible    id:screen-${app}    timeout=3s
        Current Screen Should Be    ${app}
        Go To Home Screen
    END

List Items Are Accessed With Scalar Syntax
    [Documentation]    Use ${list}[index] — never @{list}[index] (deprecated).
    [Tags]    variables    tutorial-09
    ${first}=    Set Variable    ${ALL_APP_SCREENS}[0]
    ${last}=     Set Variable    ${ALL_APP_SCREENS}[-1]
    Should Be Equal    ${first}    navigation
    Should Be Equal    ${last}     weather

Dictionary Groups Related Values
    [Documentation]    &{dict} accessed with ${dict}[key] — readable and refactorable.
    [Tags]    variables    settings    tutorial-09
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    id:screen-settings    timeout=3s
    Element Text Should Be
    ...    id:settings-theme-toggle
    ...    ${DARK_THEME_STATE}[button_text]
    ${state}=    Get Element Attribute    id:settings-theme-toggle    data-state
    Should Be Equal    ${state}    ${DARK_THEME_STATE}[data_state]

Seat Heat Cycles Through All States From Variable File
    [Documentation]    SEAT_HEAT_STATES from climate_config.py drives the expected cycle values.
    [Tags]    variables    climate    tutorial-09
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    ${CLIMATE_SCREEN}    timeout=3s
    FOR    ${expected_state}    IN    @{SEAT_HEAT_STATES}
        Click Button    id:climate-driver-seat-heat
        ${actual}=    Get Element Attribute    id:climate-driver-seat-heat    data-state
        Should Be Equal    ${actual}    ${expected_state}
    END

Built-In Variables Log To Html
    [Documentation]    Demonstrates ${TEST NAME}, ${SUITE NAME}, ${CURDIR}, ${EXECDIR}.
    [Tags]    variables    tutorial-09
    Log    Test: ${TEST NAME}
    Log    Suite: ${SUITE NAME}
    Log    File dir: ${CURDIR}
    Log    Invocation dir: ${EXECDIR}
    Log    TRUE=${TRUE} FALSE=${FALSE} EMPTY="${EMPTY}"
    Should Be True    ${TRUE}
    Should Not Be True    ${FALSE}
    Should Be Equal    ${EMPTY}    ${EMPTY}
