*** Settings ***
Documentation    Tutorial 11 — Media screen tests using media_page.resource.
...              Teaches: resource-based locators, data-state attribute assertions.

Resource         ${CURDIR}/../../resources/media_page.resource

Suite Setup      Open Media Screen
Suite Teardown   Close All Browsers
Test Setup       Reset Media Screen
Test Teardown    Capture Screenshot On Failure

Test Tags    media    tutorial-11

*** Test Cases ***
Track Name Is Not Empty On Load
    [Tags]    smoke
    ${name}=    Get Current Track Name
    Should Not Be Empty    ${name}
    ...    msg=Track name was empty on media screen load

Artist Name Is Not Empty On Load
    [Tags]    smoke
    ${artist}=    Get Text    ${ARTIST_NAME}
    Should Not Be Empty    ${artist}

Media Starts In Playing State
    [Tags]    smoke
    Playback State Should Be    playing

Play Pause Toggles State To Paused
    ${state}=    Toggle Playback
    Should Be Equal    ${state}    paused

Play Pause Toggles Back To Playing
    Toggle Playback
    Toggle Playback
    Playback State Should Be    playing

Next Track Changes Track Name
    ${before}=    Get Current Track Name
    Click Button    ${NEXT_BTN}
    ${after}=     Get Current Track Name
    Should Not Be Equal    ${before}    ${after}
    ...    msg=Track name did not change after clicking Next

Previous Track Changes Track Name
    Click Button    ${NEXT_BTN}
    ${before}=    Get Current Track Name
    Click Button    ${PREV_BTN}
    ${after}=     Get Current Track Name
    Should Not Be Equal    ${before}    ${after}

Volume Increases By 5 Each Click
    ${before}=    Get Volume Level
    Click Button    ${VOLUME_UP_BTN}
    ${after}=     Get Volume Level
    ${diff}=    Evaluate    ${after} - ${before}
    Should Be Equal As Integers    ${diff}    5

Volume Decreases By 5 Each Click
    ${before}=    Get Volume Level
    Click Button    ${VOLUME_DOWN_BTN}
    ${after}=     Get Volume Level
    ${diff}=    Evaluate    ${before} - ${after}
    Should Be Equal As Integers    ${diff}    5

Bluetooth Source Tab Becomes Active
    Switch Media Source To    bluetooth
    ${class}=    Get Element Attribute    ${SOURCE_BT_TAB}    class
    Should Contain    ${class}    active

Radio Source Tab Is Active By Default
    ${class}=    Get Element Attribute    ${SOURCE_RADIO_TAB}    class
    Should Contain    ${class}    active

*** Keywords ***
Reset Media Screen
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    ${MEDIA_SCREEN}    timeout=3s
