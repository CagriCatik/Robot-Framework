*** Settings ***
Documentation    Page-object resource for the simulator climate screen.
Resource         simulator_ui.resource

*** Variables ***
${CLIMATE_SCREEN}             id:screen-climate
${DRIVER_TEMP_VALUE}          id:climate-temperature-value
${DRIVER_TEMP_UP_BUTTON}      id:climate-temp-up
${DRIVER_SEAT_HEAT_BUTTON}    id:climate-driver-seat-heat
${AC_TOGGLE}                  id:climate-ac-toggle

*** Keywords ***
Open Climate Screen
    Open Simulator App    climate
    Element Should Be Visible    ${CLIMATE_SCREEN}

Driver Temperature Should Increase
    ${before}    ${after}=    Element Numeric Text Should Increase After Click    ${DRIVER_TEMP_VALUE}    ${DRIVER_TEMP_UP_BUTTON}
    Log    Driver temperature changed from ${before} to ${after}

Driver Seat Heat Should Cycle
    Element Attribute Value Should Be    ${DRIVER_SEAT_HEAT_BUTTON}    data-state    off
    Click Button    ${DRIVER_SEAT_HEAT_BUTTON}
    Element Attribute Value Should Be    ${DRIVER_SEAT_HEAT_BUTTON}    data-state    low
    Click Button    ${DRIVER_SEAT_HEAT_BUTTON}
    Element Attribute Value Should Be    ${DRIVER_SEAT_HEAT_BUTTON}    data-state    high
    Click Button    ${DRIVER_SEAT_HEAT_BUTTON}
    Element Attribute Value Should Be    ${DRIVER_SEAT_HEAT_BUTTON}    data-state    off

AC Toggle Should Change State
    Element Data State Should Change After Click    ${AC_TOGGLE}

