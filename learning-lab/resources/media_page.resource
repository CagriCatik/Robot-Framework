*** Settings ***
Resource    ${CURDIR}/common.resource

*** Variables ***
${MEDIA_SCREEN}          id:screen-media
${TRACK_NAME}            id:media-track-name
${ARTIST_NAME}           id:media-artist-name
${SOURCE_DISPLAY}        id:media-source-display
${PLAY_PAUSE_BTN}        id:media-play-pause-button
${NEXT_BTN}              id:media-next-button
${PREV_BTN}              id:media-prev-button
${VOLUME_VALUE}          id:media-volume-value
${VOLUME_UP_BTN}         id:media-volume-up
${VOLUME_DOWN_BTN}       id:media-volume-down
${VOLUME_FILL}           id:media-volume-fill
${SOURCE_RADIO_TAB}      id:media-source-radio
${SOURCE_BT_TAB}         id:media-source-bluetooth
${SOURCE_USB_TAB}        id:media-source-usb
${ELAPSED_TIME}          id:media-elapsed-time
${TOTAL_TIME}            id:media-total-time

*** Keywords ***
Open Media Screen
    [Documentation]    Opens the browser and navigates to the Media screen.
    Open Simulator
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    ${MEDIA_SCREEN}    timeout=3s

Get Current Track Name
    [Documentation]    Returns the track name text currently displayed.
    ${name}=    Get Text    ${TRACK_NAME}
    RETURN    ${name}

Get Volume Level
    [Documentation]    Returns the current volume as an integer.
    ${raw}=    Get Text    ${VOLUME_VALUE}
    ${vol}=    Convert To Integer    ${raw}
    RETURN    ${vol}

Toggle Playback
    [Documentation]    Clicks play/pause. Returns the new data-state ("playing" or "paused").
    Click Button    ${PLAY_PAUSE_BTN}
    ${state}=    Get Element Attribute    ${PLAY_PAUSE_BTN}    data-state
    RETURN    ${state}

Toggle Playback And Return State
    [Documentation]    Alias kept for compatibility with example_project test patterns.
    ${state}=    Toggle Playback
    RETURN    ${state}

Playback State Should Be
    [Arguments]    ${expected}
    Element Attribute Value Should Be    ${PLAY_PAUSE_BTN}    data-state    ${expected}

Switch Media Source To
    [Documentation]    Clicks the source tab. source must be radio, bluetooth, or usb.
    [Arguments]    ${source}
    Click Button    id:media-source-${source}
    Wait Until Page Contains Element    css:#media-source-${source}.active    timeout=2s

Bluetooth Source Can Be Selected
    [Documentation]    Switches to Bluetooth source and asserts the source display updates.
    Switch Media Source To    bluetooth
    ${text}=    Get Text    ${SOURCE_DISPLAY}
    Should Contain    ${text.upper()}    BLUETOOTH

Media Volume Should Increase
    [Documentation]    Clicks volume up once and asserts the numeric value went up.
    Element Numeric Text Should Increase After Click    ${VOLUME_VALUE}    ${VOLUME_UP_BTN}

Volume Should Be
    [Arguments]    ${expected}
    ${actual}=    Get Volume Level
    Should Be Equal As Integers    ${actual}    ${expected}
    ...    msg=Volume: expected ${expected}, got ${actual}
