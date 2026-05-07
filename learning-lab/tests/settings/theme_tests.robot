*** Settings ***
Documentation    Tutorial 11 — Settings screen tests using settings_page.resource.

Resource         ${CURDIR}/../../resources/settings_page.resource

Suite Setup      Open Settings Screen
Suite Teardown   Close All Browsers
Test Setup       Restore Settings Screen
Test Teardown    Capture Screenshot On Failure

Test Tags    settings    tutorial-11

*** Test Cases ***
Default Theme Is Dark
    [Tags]    smoke    theme
    Theme State Should Be    dark

Theme Toggle Switches To Light Mode
    [Tags]    smoke    theme
    Toggle Theme
    Theme State Should Be    light
    Toggle Theme    # restore

Default Brightness Is 80 Percent
    Brightness Should Be    80%

Brightness Increases When Up Is Clicked
    ${before}=    Get Brightness Value
    Click Button    ${BRIGHTNESS_UP_BTN}
    ${after}=     Get Brightness Value
    Should Not Be Equal    ${before}    ${after}

Brightness Decreases When Down Is Clicked
    ${before}=    Get Brightness Value
    Click Button    ${BRIGHTNESS_DOWN_BTN}
    ${after}=     Get Brightness Value
    Should Not Be Equal    ${before}    ${after}

Wi-Fi Is Enabled By Default
    [Tags]    smoke    connectivity
    Wi-Fi State Should Be    on

Wi-Fi Toggle Changes State
    [Tags]    connectivity
    Click Button    ${WIFI_TOGGLE}
    Wi-Fi State Should Be    off
    Click Button    ${WIFI_TOGGLE}
    Wi-Fi State Should Be    on

System Version Is Displayed
    ${version}=    Get Text    ${VERSION_VALUE}
    Should Contain    ${version}    AutoCenter OS

Language Can Be Switched To German
    Select From List By Value    ${LANGUAGE_SELECT}    de
    ${selected}=    Get Selected List Value    ${LANGUAGE_SELECT}
    Should Be Equal    ${selected}    de
    Select From List By Value    ${LANGUAGE_SELECT}    en

Units Toggle Switches To Imperial
    ${before}=    Get Element Attribute    ${UNITS_TOGGLE}    data-state
    Should Be Equal    ${before}    metric
    Click Button    ${UNITS_TOGGLE}
    ${after}=    Get Element Attribute    ${UNITS_TOGGLE}    data-state
    Should Be Equal    ${after}    imperial
    Click Button    ${UNITS_TOGGLE}    # restore

*** Keywords ***
Restore Settings Screen
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    ${SETTINGS_SCREEN}    timeout=3s
