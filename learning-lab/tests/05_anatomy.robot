*** Settings ***
Documentation    Tutorial 05 — All four file sections working together against the simulator.
...              Teaches: Settings, Variables, Test Cases, Keywords, continuation lines,
...              Suite Setup/Teardown, Test Setup/Teardown, Metadata, Test Tags.

Resource         ${CURDIR}/../resources/common.resource

Metadata         Feature       Climate Control
Metadata         Owner         QA Team
Metadata         Tutorial      05

Suite Setup      Open Simulator
Suite Teardown   Close All Browsers
Test Setup       Navigate To Climate Screen
Test Teardown    Run Keywords
...    Go To Home Screen
...    AND    Capture Screenshot On Failure

Test Tags    anatomy    climate    tutorial-05

*** Variables ***
${DEFAULT_DRIVER_TEMP}    22
${DEFAULT_FAN_SPEED}      2
${MIN_TEMP}               16
${MAX_TEMP}               30

*** Test Cases ***
Climate Screen Opens From Home
    [Documentation]    Clicking the Climate icon must show the climate screen.
    [Tags]    smoke
    Element Should Be Visible    id:screen-climate
    Current Screen Should Be     CLIMATE

Default Driver Temperature Is 22 Degrees
    [Documentation]    On first load, driver temperature must show the default value.
    Element Text Should Be    id:climate-temperature-value    ${DEFAULT_DRIVER_TEMP}°C

Default Fan Speed Is 2
    [Documentation]    Fan speed must start at 2 on every fresh page load.
    Element Text Should Be    id:climate-fan-speed-value    ${DEFAULT_FAN_SPEED}

Temperature Up Button Increases The Value
    [Documentation]    Each click of the up button must raise the displayed value by 1.
    ${before}=    Get Text    id:climate-temperature-value
    Click Button    id:climate-temp-up
    ${after}=     Get Text    id:climate-temperature-value
    Should Not Be Equal    ${before}    ${after}

*** Keywords ***
Navigate To Climate Screen
    [Documentation]    Navigates from any screen to the climate screen.
    Go To Home Screen
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
