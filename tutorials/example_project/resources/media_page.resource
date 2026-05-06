*** Settings ***
Documentation    Page-object resource for the simulator media screen.
Resource         simulator_ui.resource

*** Variables ***
${MEDIA_SCREEN}          id:screen-media
${PLAY_PAUSE_BUTTON}     id:media-play-pause-button
${VOLUME_VALUE}          id:media-volume-value
${VOLUME_UP_BUTTON}      id:media-volume-up
${SOURCE_BLUETOOTH}      id:media-source-bluetooth
${SOURCE_DISPLAY}        id:media-source-display

*** Keywords ***
Open Media Screen
    Open Simulator App    media
    Element Should Be Visible    ${MEDIA_SCREEN}

Toggle Playback And Return State
    Click Button    ${PLAY_PAUSE_BUTTON}
    ${state}=    Get Element Attribute    ${PLAY_PAUSE_BUTTON}    data-state
    RETURN    ${state}

Media Volume Should Increase
    ${before}    ${after}=    Element Numeric Text Should Increase After Click    ${VOLUME_VALUE}    ${VOLUME_UP_BUTTON}
    Log    Media volume changed from ${before} to ${after}

Bluetooth Source Can Be Selected
    Click Button    ${SOURCE_BLUETOOTH}
    Element Text Should Be    ${SOURCE_DISPLAY}    BLUETOOTH AUDIO
