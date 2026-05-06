*** Settings ***
Documentation    Page-object resource for the simulator vehicle status screen.
Resource         simulator_ui.resource

*** Variables ***
${VEHICLE_SCREEN}         id:screen-vehicle
${FUEL_VALUE}             id:vehicle-fuel-value
${BATTERY_VALUE}          id:vehicle-battery-value
${ODOMETER_VALUE}         id:vehicle-odometer-value
${TIRE_FRONT_LEFT_VALUE}  id:vehicle-tire-fl-value

*** Keywords ***
Open Vehicle Screen
    Open Simulator App    vehicle
    Element Should Be Visible    ${VEHICLE_SCREEN}

Vehicle Gauges Should Be Visible
    Element Should Be Visible    ${FUEL_VALUE}
    Element Should Be Visible    ${BATTERY_VALUE}
    Element Should Be Visible    ${ODOMETER_VALUE}
    Element Should Be Visible    ${TIRE_FRONT_LEFT_VALUE}

Fuel Percentage Should Be Plausible
    ${fuel_text}=    Get Text    ${FUEL_VALUE}
    ${fuel}=    Parse Number    ${fuel_text}
    Should Be True    0 <= ${fuel} <= 100

