*** Settings ***
Resource    ${CURDIR}/common.resource

*** Variables ***
${VEHICLE_SCREEN}          id:screen-vehicle
${FUEL_VALUE}              id:vehicle-fuel-value
${FUEL_GAUGE}              id:vehicle-fuel-gauge
${BATTERY_VALUE}           id:vehicle-battery-value
${OIL_VALUE}               id:vehicle-oil-value
${ODOMETER_VALUE}          id:vehicle-odometer-value
${SPEED_VALUE}             id:vehicle-speed-value
${TRIP_VALUE}              id:vehicle-trip-value
${TIRE_FL}                 id:vehicle-tire-fl
${TIRE_FR}                 id:vehicle-tire-fr
${TIRE_RL}                 id:vehicle-tire-rl
${TIRE_RR}                 id:vehicle-tire-rr
${TIRE_FL_VALUE}           id:vehicle-tire-fl-value
${TIRE_FR_VALUE}           id:vehicle-tire-fr-value
${TIRE_RL_VALUE}           id:vehicle-tire-rl-value
${TIRE_RR_VALUE}           id:vehicle-tire-rr-value

*** Keywords ***
Open Vehicle Screen
    [Documentation]    Opens the browser and navigates to the Vehicle Status screen.
    Open Simulator
    Click Button    id:app-icon-vehicle
    Wait Until Element Is Visible    ${VEHICLE_SCREEN}    timeout=3s

Vehicle Gauges Should Be Visible
    Element Should Be Visible    ${FUEL_VALUE}
    Element Should Be Visible    ${BATTERY_VALUE}
    Element Should Be Visible    ${ODOMETER_VALUE}
    Element Should Be Visible    ${TIRE_FL_VALUE}

Fuel Percentage Should Be Plausible
    [Documentation]    Reads the fuel value and asserts it is between 0 and 100.
    ${fuel_text}=    Get Text    ${FUEL_VALUE}
    ${fuel}=    Parse Number    ${fuel_text}
    Should Be True    0 <= ${fuel} <= 100
    ...    msg=Fuel value ${fuel_text} is outside the valid 0–100% range

All Tire Pressures Should Be OK
    [Documentation]    Asserts that all four tire data-state attributes equal "ok".
    FOR    ${tire_id}    IN    ${TIRE_FL}    ${TIRE_FR}    ${TIRE_RL}    ${TIRE_RR}
        Element Attribute Value Should Be    ${tire_id}    data-state    ok
    END

Fuel Level Should Be
    [Documentation]    Asserts the fuel percentage text, e.g. "75%".
    [Arguments]    ${expected_percent}
    ${actual}=    Get Text    ${FUEL_VALUE}
    Should Be Equal    ${actual}    ${expected_percent}
    ...    msg=Fuel level: expected ${expected_percent}, got ${actual}
