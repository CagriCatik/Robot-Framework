*** Settings ***
Resource    ${CURDIR}/common.resource

*** Variables ***
${CLIMATE_SCREEN}           id:screen-climate
${DRIVER_TEMP_DISPLAY}      id:climate-temperature-value
${PASSENGER_TEMP_DISPLAY}   id:climate-passenger-temp-value
${TEMP_UP_BTN}              id:climate-temp-up
${TEMP_DOWN_BTN}            id:climate-temp-down
${FAN_SPEED_DISPLAY}        id:climate-fan-speed-value
${FAN_UP_BTN}               id:climate-fan-up
${FAN_DOWN_BTN}             id:climate-fan-down
${DRIVER_SEAT_HEAT_BTN}     id:climate-driver-seat-heat
${PASSENGER_SEAT_HEAT_BTN}  id:climate-passenger-seat-heat
${AC_TOGGLE}                id:climate-ac-toggle
${SYNC_TOGGLE}              id:climate-sync-toggle
${DEFROST_TOGGLE}           id:climate-defrost-toggle
${RECIRC_TOGGLE}            id:climate-recirculate-toggle

*** Keywords ***
Open Climate Screen
    [Documentation]    Opens the browser and navigates to the Climate screen.
    Open Simulator
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    ${CLIMATE_SCREEN}    timeout=3s

Get Driver Temperature
    [Documentation]    Returns the driver temperature string, e.g. "22°C".
    ${value}=    Get Text    ${DRIVER_TEMP_DISPLAY}
    RETURN    ${value}

Get Passenger Temperature
    [Documentation]    Returns the passenger temperature string, e.g. "21°C".
    ${value}=    Get Text    ${PASSENGER_TEMP_DISPLAY}
    RETURN    ${value}

Driver Temperature Should Be
    [Documentation]    Asserts the driver temperature display equals expected (e.g. "24°C").
    [Arguments]    ${expected}
    ${actual}=    Get Driver Temperature
    Should Be Equal    ${actual}    ${expected}
    ...    msg=Driver temp: expected ${expected}, got ${actual}

Set Driver Temperature To
    [Documentation]    Clicks up or down until the driver temperature matches target (integer 16–30).
    [Arguments]    ${target_celsius}
    ${current_str}=    Get Driver Temperature
    ${current}=    Evaluate    int("${current_str}".replace("°C",""))
    ${diff}=    Evaluate    int(${target_celsius}) - ${current}
    IF    ${diff} > 0
        FOR    ${i}    IN RANGE    ${diff}
            Click Button    ${TEMP_UP_BTN}
        END
    ELSE IF    ${diff} < 0
        FOR    ${i}    IN RANGE    ${{ abs(int(${diff})) }}
            Click Button    ${TEMP_DOWN_BTN}
        END
    END

Driver Temperature Should Increase
    [Documentation]    Clicks the up button once and asserts the value increased.
    Element Numeric Text Should Increase After Click    ${DRIVER_TEMP_DISPLAY}    ${TEMP_UP_BTN}

Get Fan Speed
    [Documentation]    Returns the fan speed as a string, e.g. "2".
    ${value}=    Get Text    ${FAN_SPEED_DISPLAY}
    RETURN    ${value}

Fan Speed Should Be
    [Arguments]    ${expected}
    ${actual}=    Get Fan Speed
    Should Be Equal    ${actual}    ${expected}
    ...    msg=Fan speed: expected ${expected}, got ${actual}

Toggle AC
    Click Button    ${AC_TOGGLE}

AC State Should Be
    [Arguments]    ${expected_state}
    Element Attribute Value Should Be    ${AC_TOGGLE}    data-state    ${expected_state}

AC Toggle Should Change State
    Element Data State Should Change After Click    ${AC_TOGGLE}

Cycle Driver Seat Heat
    [Documentation]    Clicks the driver seat heat button once. Returns new state (off/low/high).
    Click Button    ${DRIVER_SEAT_HEAT_BTN}
    ${state}=    Get Element Attribute    ${DRIVER_SEAT_HEAT_BTN}    data-state
    RETURN    ${state}

Driver Seat Heat State Should Be
    [Arguments]    ${expected}
    Element Attribute Value Should Be    ${DRIVER_SEAT_HEAT_BTN}    data-state    ${expected}

Driver Seat Heat Should Cycle
    [Documentation]    Asserts the full off→low→high→off cycle.
    Element Attribute Value Should Be    ${DRIVER_SEAT_HEAT_BTN}    data-state    off
    Click Button    ${DRIVER_SEAT_HEAT_BTN}
    Element Attribute Value Should Be    ${DRIVER_SEAT_HEAT_BTN}    data-state    low
    Click Button    ${DRIVER_SEAT_HEAT_BTN}
    Element Attribute Value Should Be    ${DRIVER_SEAT_HEAT_BTN}    data-state    high
    Click Button    ${DRIVER_SEAT_HEAT_BTN}
    Element Attribute Value Should Be    ${DRIVER_SEAT_HEAT_BTN}    data-state    off
