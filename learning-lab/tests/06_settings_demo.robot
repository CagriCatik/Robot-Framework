*** Settings ***
Documentation    Tutorial 06 — Settings section: library args, variables file, hooks, tags, timeout.
...              Teaches: Library constructor arguments, Variables import, metadata, Test Tags,
...              Suite Setup/Teardown, Test Setup/Teardown, Test Timeout.

Library          SeleniumLibrary    timeout=10    run_on_failure=Capture Page Screenshot
Resource         ${CURDIR}/../resources/common.resource
Resource         ${CURDIR}/../resources/settings_page.resource
Variables        ${CURDIR}/../data/environments.py

Metadata         Feature       Settings Screen
Metadata         Ticket        SIM-042
Metadata         Tutorial      06

Suite Setup      Open Settings Screen
Suite Teardown   Close All Browsers
Test Setup       Settings Screen Should Be Open
Test Teardown    Restore Settings Screen

Test Tags        settings    regression    tutorial-06
Test Timeout     1 minute

*** Test Cases ***
Theme Toggles Between Dark And Light
    [Documentation]    Clicking the theme toggle must flip the data-state attribute.
    [Tags]    smoke    theme
    Theme State Should Be    dark
    ${new_state}=    Toggle Theme
    Should Be Equal    ${new_state}    light
    ${reverted}=    Toggle Theme
    Should Be Equal    ${reverted}    dark

Brightness Increases By 10 Per Click
    [Documentation]    Each click of the up button must increase the brightness value.
    ${before}=    Get Brightness Value
    Click Button    ${BRIGHTNESS_UP_BTN}
    ${after}=     Get Brightness Value
    Should Not Be Equal    ${before}    ${after}

Wi-Fi Toggle Changes State
    [Documentation]    Wi-Fi must toggle between "on" and "off" on each click.
    [Tags]    connectivity
    Wi-Fi State Should Be    on
    Click Button    ${WIFI_TOGGLE}
    Wi-Fi State Should Be    off
    Click Button    ${WIFI_TOGGLE}
    Wi-Fi State Should Be    on

Language Selection Can Be Changed
    [Documentation]    The language dropdown must accept and hold a new selection.
    Select From List By Value    ${LANGUAGE_SELECT}    de
    ${selected}=    Get Selected List Value    ${LANGUAGE_SELECT}
    Should Be Equal    ${selected}    de
    Select From List By Value    ${LANGUAGE_SELECT}    en

*** Keywords ***
Settings Screen Should Be Open
    Element Should Be Visible    ${SETTINGS_SCREEN}

Restore Settings Screen
    Run Keyword If Test Failed    Capture Page Screenshot
    Go To Home Screen
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    ${SETTINGS_SCREEN}    timeout=3s
