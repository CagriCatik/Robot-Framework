*** Settings ***
Documentation    Tutorial 01 — Your first real automation tests against the simulator.
...              Teaches: Open Browser, element visibility, text assertion, teardown.

Resource         ${CURDIR}/../resources/common.resource

*** Test Cases ***
Home Screen Loads With All App Icons
    [Documentation]    The home screen must show all eight app icons on first load.
    [Tags]    smoke    home    tutorial-01
    Open Simulator
    Element Should Be Visible    id:app-icon-navigation
    Element Should Be Visible    id:app-icon-media
    Element Should Be Visible    id:app-icon-climate
    Element Should Be Visible    id:app-icon-phone
    Element Should Be Visible    id:app-icon-vehicle
    Element Should Be Visible    id:app-icon-settings
    Element Should Be Visible    id:app-icon-camera
    Element Should Be Visible    id:app-icon-weather
    [Teardown]    Close Browser

Clicking Climate Icon Opens Climate Screen
    [Documentation]    Clicking an app icon must change the active screen and update the indicator.
    [Tags]    smoke    navigation    tutorial-01
    Open Simulator
    Element Text Should Be    id:nav-current-screen    HOME
    Click Button    id:app-icon-climate
    Wait Until Element Contains    id:nav-current-screen    CLIMATE    timeout=3s
    Element Should Be Visible    id:screen-climate
    Click Button    id:nav-home-button
    Wait Until Element Contains    id:nav-current-screen    HOME    timeout=3s
    [Teardown]    Close Browser

Settings Screen Is Reachable From Home
    [Documentation]    BDD-style: each step maps directly to a user-level keyword.
    [Tags]    smoke    bdd    tutorial-01
    Given the simulator is open
    When the user opens settings
    Then the settings screen is visible
    [Teardown]    Close Browser

Navigation Search Updates Destination Display
    [Documentation]    Typing a destination and clicking Search must populate the display fields.
    [Tags]    navigation    tutorial-01
    Open Simulator
    Click Button    id:app-icon-navigation
    Wait Until Element Is Visible    id:screen-navigation    timeout=3s
    Input Text    id:nav-destination-input    Berlin City Centre
    Click Button    id:nav-search-button
    Wait Until Element Does Not Contain    id:nav-destination-display    ---    timeout=3s
    ${dest}=    Get Text    id:nav-destination-display
    Should Be Equal    ${dest}    Berlin City Centre
    ${eta}=    Get Text    id:nav-eta-display
    Should Not Be Equal    ${eta}    ---
    [Teardown]    Close Browser

*** Keywords ***
the simulator is open
    Open Simulator

the user opens settings
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    id:screen-settings    timeout=3s

the settings screen is visible
    Element Text Should Be    id:nav-current-screen    SETTINGS
    Element Should Be Visible    id:screen-settings
