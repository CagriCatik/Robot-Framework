*** Settings ***
Documentation    Page-object resource for the simulator settings screen.
Resource         simulator_ui.resource

*** Variables ***
${SETTINGS_SCREEN}       id:screen-settings
${THEME_TOGGLE}          id:settings-theme-toggle
${UNITS_TOGGLE}          id:settings-units-toggle
${BRIGHTNESS_VALUE}      id:settings-brightness-value
${BRIGHTNESS_UP_BUTTON}  id:settings-brightness-up

*** Keywords ***
Open Settings Screen
    Open Simulator App    settings
    Element Should Be Visible    ${SETTINGS_SCREEN}

Theme Toggle Should Change State
    Element Data State Should Change After Click    ${THEME_TOGGLE}

Units Toggle Should Switch To Imperial
    Element Text Should Be    ${UNITS_TOGGLE}    Metric
    Click Button    ${UNITS_TOGGLE}
    Element Text Should Be    ${UNITS_TOGGLE}    Imperial

Brightness Should Increase
    Element Numeric Text Should Increase After Click    ${BRIGHTNESS_VALUE}    ${BRIGHTNESS_UP_BUTTON}

