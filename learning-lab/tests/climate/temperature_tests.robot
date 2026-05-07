*** Settings ***
Documentation    Tutorial 11 — Climate temperature tests using climate_page.resource.
...              Every locator lives in the resource. Tests call business-level keywords only.

Resource         ${CURDIR}/../../resources/climate_page.resource

Suite Setup      Open Climate Screen
Suite Teardown   Close All Browsers
Test Setup       Reset Climate Screen
Test Teardown    Run Keywords
...    Go To Home Screen
...    AND    Capture Screenshot On Failure

Test Tags    climate    temperature    tutorial-11

*** Test Cases ***
Driver Temperature Starts At 22
    [Tags]    smoke
    Driver Temperature Should Be    22°C

Temperature Increases By One Per Click
    ${before}=    Get Driver Temperature
    Click Button    ${TEMP_UP_BTN}
    ${after}=     Get Driver Temperature
    Should Not Be Equal    ${before}    ${after}

Temperature Can Be Set To A Specific Value
    Set Driver Temperature To    26
    Driver Temperature Should Be    26°C

Temperature Cannot Exceed 30 Degrees
    FOR    ${i}    IN RANGE    20
        Click Button    ${TEMP_UP_BTN}
    END
    Driver Temperature Should Be    30°C

Temperature Cannot Drop Below 16 Degrees
    FOR    ${i}    IN RANGE    20
        Click Button    ${TEMP_DOWN_BTN}
    END
    Driver Temperature Should Be    16°C

AC Starts Enabled
    [Tags]    smoke
    AC State Should Be    on

AC Toggle Turns AC Off Then Back On
    AC State Should Be    on
    Toggle AC
    AC State Should Be    off
    Toggle AC
    AC State Should Be    on

Seat Heat Cycles Off Low High Off
    ${s1}=    Cycle Driver Seat Heat
    Should Be Equal    ${s1}    low
    ${s2}=    Cycle Driver Seat Heat
    Should Be Equal    ${s2}    high
    ${s3}=    Cycle Driver Seat Heat
    Should Be Equal    ${s3}    off

*** Keywords ***
Reset Climate Screen
    [Documentation]    Returns to the climate screen in a known fresh state.
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    ${CLIMATE_SCREEN}    timeout=3s
