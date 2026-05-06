*** Settings ***
Documentation    Page-object resource for the simulator safety camera screen.
Resource         simulator_ui.resource

*** Variables ***
${CAMERA_SCREEN}          id:screen-camera
${CAMERA_FEED}            id:camera-feed
${FRONT_VIEW_BUTTON}      id:camera-view-front
${CAMERA_VIEW_LABEL}      id:camera-view-label
${REAR_LEFT_SENSOR}       id:sensor-rear-left
${REAR_DISTANCE_TEXT}     id:sensor-rear-distance
${OBSTACLE_NEAR_BUTTON}   id:camera-sim-obstacle-near
${OBSTACLE_CLEAR_BUTTON}  id:camera-sim-obstacle-clear

*** Keywords ***
Open Camera Screen
    Open Simulator App    camera
    Element Should Be Visible    ${CAMERA_SCREEN}

Camera View Can Switch To Front
    Element Text Should Be    ${CAMERA_VIEW_LABEL}    REAR VIEW
    Click Button    ${FRONT_VIEW_BUTTON}
    Element Text Should Be    ${CAMERA_VIEW_LABEL}    FRONT VIEW
    Element Attribute Value Should Be    ${CAMERA_FEED}    data-view    front

Near Obstacle Should Update Rear Sensors
    Element Attribute Value Should Be    ${REAR_LEFT_SENSOR}    data-state    clear
    Click Button    ${OBSTACLE_NEAR_BUTTON}
    Element Attribute Value Should Be    ${REAR_LEFT_SENSOR}    data-state    near
    Element Text Should Be    ${REAR_DISTANCE_TEXT}    < 0.3 m
    Click Button    ${OBSTACLE_CLEAR_BUTTON}
    Element Attribute Value Should Be    ${REAR_LEFT_SENSOR}    data-state    clear

