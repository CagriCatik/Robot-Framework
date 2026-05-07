*** Settings ***
Resource    ${CURDIR}/common.resource

*** Variables ***
${CAMERA_SCREEN}            id:screen-camera
${CAMERA_FEED}              id:camera-feed
${CAMERA_VIEW_LABEL}        id:camera-view-label
${FRONT_VIEW_BTN}           id:camera-view-front
${REAR_VIEW_BTN}            id:camera-view-rear
${VIEW_360_BTN}             id:camera-view-360
${REAR_LEFT_SENSOR}         id:sensor-rear-left
${REAR_DISTANCE_TEXT}       id:sensor-rear-distance
${FRONT_DISTANCE_TEXT}      id:sensor-front-distance
${OBSTACLE_NEAR_BTN}        id:camera-sim-obstacle-near
${OBSTACLE_MEDIUM_BTN}      id:camera-sim-obstacle-medium
${OBSTACLE_CLEAR_BTN}       id:camera-sim-obstacle-clear

*** Keywords ***
Open Camera Screen
    [Documentation]    Opens the browser and navigates to the Camera screen.
    Open Simulator
    Click Button    id:app-icon-camera
    Wait Until Element Is Visible    ${CAMERA_SCREEN}    timeout=3s

Camera View Can Switch To Front
    [Documentation]    Asserts rear view is default, clicks Front, asserts the change.
    Element Text Should Be    ${CAMERA_VIEW_LABEL}    REAR VIEW
    Click Button    ${FRONT_VIEW_BTN}
    Element Text Should Be    ${CAMERA_VIEW_LABEL}    FRONT VIEW
    Element Attribute Value Should Be    ${CAMERA_FEED}    data-view    front

Near Obstacle Should Update Rear Sensors
    [Documentation]    Simulates a near obstacle and asserts sensor state + distance text change.
    Element Attribute Value Should Be    ${REAR_LEFT_SENSOR}    data-state    clear
    Click Button    ${OBSTACLE_NEAR_BTN}
    Element Attribute Value Should Be    ${REAR_LEFT_SENSOR}    data-state    near
    Element Text Should Be    ${REAR_DISTANCE_TEXT}    < 0.3 m
    Click Button    ${OBSTACLE_CLEAR_BTN}
    Element Attribute Value Should Be    ${REAR_LEFT_SENSOR}    data-state    clear

Sensor State Should Be
    [Documentation]    Asserts the data-state of any sensor dot element.
    [Arguments]    ${sensor_id}    ${expected_state}
    Element Attribute Value Should Be    ${sensor_id}    data-state    ${expected_state}
