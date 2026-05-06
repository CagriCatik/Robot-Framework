*** Settings ***
Documentation     Section 08 showing useful logs, screenshots, runtime variables, and output artifacts.
Resource          ../resources/camera_page.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-08    execution-logging

*** Test Cases ***
Execution Artifacts Capture Real Browser Evidence
    [Tags]    smoke
    Open Camera Screen
    Capture Evidence Screenshot    camera-default
    File Should Exist    ${OUTPUT DIR}/${SCREENSHOT_SUBDIR}/camera-default.png

Logs Can Explain A Real UI State Change
    Open Camera Screen
    Log Variables
    Near Obstacle Should Update Rear Sensors
    Capture Evidence Screenshot    camera-obstacle-cleared

Command Line Variables Can Still Override Project Values
    Log    Browser target URL: ${SIMULATOR_URL}
    Should Start With    ${SIMULATOR_URL}    file:///

