*** Settings ***
Resource    ${CURDIR}/common.resource

*** Variables ***
${SETTINGS_SCREEN}       id:screen-settings
${THEME_TOGGLE}          id:settings-theme-toggle
${BRIGHTNESS_UP_BTN}     id:settings-brightness-up
${BRIGHTNESS_DOWN_BTN}   id:settings-brightness-down
${BRIGHTNESS_VALUE}      id:settings-brightness-value
${LANGUAGE_SELECT}       id:settings-language-select
${UNITS_TOGGLE}          id:settings-units-toggle
${BT_TOGGLE}             id:settings-bluetooth-toggle
${WIFI_TOGGLE}           id:settings-wifi-toggle
${VERSION_VALUE}         id:settings-version-value

*** Keywords ***
Open Settings Screen
    [Documentation]    Opens the browser and navigates to the Settings screen.
    Open Simulator
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    ${SETTINGS_SCREEN}    timeout=3s

Theme State Should Be
    [Arguments]    ${expected}
    Element Attribute Value Should Be    ${THEME_TOGGLE}    data-state    ${expected}

Toggle Theme
    [Documentation]    Clicks the theme toggle and returns the new data-state.
    Click Button    ${THEME_TOGGLE}
    ${state}=    Get Element Attribute    ${THEME_TOGGLE}    data-state
    RETURN    ${state}

Theme Toggle Should Change State
    Element Data State Should Change After Click    ${THEME_TOGGLE}

Get Brightness Value
    [Documentation]    Returns brightness text, e.g. "80%".
    ${val}=    Get Text    ${BRIGHTNESS_VALUE}
    RETURN    ${val}

Brightness Should Be
    [Arguments]    ${expected}
    ${actual}=    Get Brightness Value
    Should Be Equal    ${actual}    ${expected}
    ...    msg=Brightness: expected ${expected}, got ${actual}

Brightness Should Increase
    [Documentation]    Clicks brightness up once and asserts the numeric value increased.
    Element Numeric Text Should Increase After Click    ${BRIGHTNESS_VALUE}    ${BRIGHTNESS_UP_BTN}

Wi-Fi State Should Be
    [Arguments]    ${expected}
    Element Attribute Value Should Be    ${WIFI_TOGGLE}    data-state    ${expected}

Units Toggle Should Switch To Imperial
    Element Text Should Be    ${UNITS_TOGGLE}    Metric
    Click Button    ${UNITS_TOGGLE}
    Element Text Should Be    ${UNITS_TOGGLE}    Imperial
    Click Button    ${UNITS_TOGGLE}    # restore to Metric
