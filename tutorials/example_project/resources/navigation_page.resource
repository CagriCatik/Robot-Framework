*** Settings ***
Documentation    Page-object resource for simulator navigation and phone examples.
Resource         simulator_ui.resource

*** Variables ***
${NAVIGATION_SCREEN}      id:screen-navigation
${PHONE_SCREEN}           id:screen-phone
${PHONE_BLUETOOTH_TOGGLE}    id:phone-bluetooth-toggle
${CONTACT_ALICE}          id:contact-alice
${PHONE_CALL_STATUS}      id:phone-call-status

*** Keywords ***
Open Navigation Screen
    Open Simulator App    navigation
    Element Should Be Visible    ${NAVIGATION_SCREEN}

Open Phone Screen
    Open Simulator App    phone
    Element Should Be Visible    ${PHONE_SCREEN}

Phone Bluetooth Toggle Should Change State
    Element Data State Should Change After Click    ${PHONE_BLUETOOTH_TOGGLE}

Calling A Contact Should Show Call Status
    Click Element    ${CONTACT_ALICE}
    Wait Until Element Is Visible    ${PHONE_CALL_STATUS}
