*** Settings ***
Resource    ${CURDIR}/common.resource

*** Variables ***
# Navigation screen
${NAV_SCREEN}              id:screen-navigation
${DESTINATION_INPUT}       id:nav-destination-input
${SEARCH_BTN}              id:nav-search-button
${DESTINATION_DISPLAY}     id:nav-destination-display
${ETA_DISPLAY}             id:nav-eta-display
${DISTANCE_DISPLAY}        id:nav-distance-display
${TURN_DISPLAY}            id:nav-turn-display
${MAP_DISPLAY}             id:nav-map-display
# Phone screen (logically grouped here — both reachable from home)
${PHONE_SCREEN}            id:screen-phone
${PHONE_BT_TOGGLE}         id:phone-bluetooth-toggle
${CONTACT_ALICE}           id:contact-alice
${PHONE_CALL_STATUS}       id:phone-call-status

*** Keywords ***
Open Navigation Screen
    [Documentation]    Opens the browser and navigates to the Navigation screen.
    Open Simulator
    Click Button    id:app-icon-navigation
    Wait Until Element Is Visible    ${NAV_SCREEN}    timeout=3s

Search For Destination
    [Documentation]    Types a destination and clicks Search. Waits for the display to update.
    [Arguments]    ${destination}
    Input Text    ${DESTINATION_INPUT}    ${destination}
    Click Button    ${SEARCH_BTN}
    Wait Until Element Does Not Contain    ${DESTINATION_DISPLAY}    ---    timeout=3s

Destination Should Be
    [Arguments]    ${expected}
    ${actual}=    Get Text    ${DESTINATION_DISPLAY}
    Should Be Equal    ${actual}    ${expected}
    ...    msg=Destination: expected '${expected}', got '${actual}'

ETA Should Be Available
    [Documentation]    Asserts the ETA display is not the placeholder "---".
    ${eta}=    Get Text    ${ETA_DISPLAY}
    Should Not Be Equal    ${eta}    ---
    ...    msg=ETA display still shows '---' after search

Open Phone Screen
    [Documentation]    Opens the browser and navigates to the Phone screen.
    Open Simulator
    Click Button    id:app-icon-phone
    Wait Until Element Is Visible    ${PHONE_SCREEN}    timeout=3s

Phone Bluetooth Toggle Should Change State
    [Documentation]    Asserts the Bluetooth toggle data-state changes on click.
    Element Data State Should Change After Click    ${PHONE_BT_TOGGLE}

Calling A Contact Should Show Call Status
    [Documentation]    Clicks the first contact and waits for the active-call overlay.
    Click Element    ${CONTACT_ALICE}
    Wait Until Element Is Visible    ${PHONE_CALL_STATUS}    timeout=3s
