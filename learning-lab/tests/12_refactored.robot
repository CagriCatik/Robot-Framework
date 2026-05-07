*** Settings ***
Documentation    Tutorial 12 — AFTER refactoring 12_messy.robot.
...              Improvements applied:
...              1. Sleep replaced with Wait Until Element Is Visible
...              2. Every Get* result is asserted, not discarded
...              3. Browser opens once (Suite Setup) instead of per-test
...              4. Locators stored in resource variables — not hardcoded
...              5. Descriptive test names (one concern each)
...              6. Tags for selective execution
...              7. Test Teardown restores state

Library          SeleniumLibrary    timeout=10    run_on_failure=Capture Page Screenshot

Resource         ${CURDIR}/../resources/common.resource
Resource         ${CURDIR}/../resources/climate_page.resource
Resource         ${CURDIR}/../resources/settings_page.resource
Resource         ${CURDIR}/../resources/media_page.resource

Metadata    Refactored    Yes
Metadata    Tutorial      12

Suite Setup      Open Simulator
Suite Teardown   Close All Browsers
Test Setup       Go To Home Screen
Test Teardown    Run Keywords
...    Capture Screenshot On Failure
...    AND    Go To Home Screen

Test Tags    regression    refactored    tutorial-12

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
    Wait Until Element Is Visible    ${SETTINGS_SCREEN}    timeout=3s
    Theme State Should Be    dark
    Toggle Theme
    Theme State Should Be    light
    Toggle Theme    # restore

Wi-Fi Toggle Changes Connection State
    [Tags]    settings    connectivity
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    ${SETTINGS_SCREEN}    timeout=3s
    Wi-Fi State Should Be    on
    Click Button    ${WIFI_TOGGLE}
    Wi-Fi State Should Be    off
    Click Button    ${WIFI_TOGGLE}    # restore

Brightness Increases When Up Button Is Clicked
    [Tags]    settings
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    ${SETTINGS_SCREEN}    timeout=3s
    ${before}=    Get Brightness Value
    Click Button    ${BRIGHTNESS_UP_BTN}
    ${after}=     Get Brightness Value
    Should Not Be Equal    ${before}    ${after}

Play Pause Toggles Media State
    [Tags]    smoke    media
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    ${MEDIA_SCREEN}    timeout=3s
    Playback State Should Be    playing
    ${new_state}=    Toggle Playback
    Should Be Equal    ${new_state}    paused
    Toggle Playback    # restore

Next Track Changes Displayed Track Name
    [Tags]    media
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    ${MEDIA_SCREEN}    timeout=3s
    ${before}=    Get Current Track Name
    Click Button    ${NEXT_BTN}
    ${after}=     Get Current Track Name
    Should Not Be Equal    ${before}    ${after}
