*** Settings ***
Documentation    Tutorial 07 — Data-driven boundary tests for temperature clamping.
...              All test cases use the same template; data rows specify inputs and expectation.

Resource         ${CURDIR}/../../resources/climate_page.resource

Suite Setup      Open Climate Screen
Suite Teardown   Close All Browsers

Test Tags    climate    boundary    data-driven    tutorial-07

# All test cases in this file use Verify Temperature Boundary
Test Template    Verify Temperature Boundary

*** Test Cases ***                  CLICKS_UP    CLICKS_DOWN    EXPECTED_TEMP
Maximum After 20 Up Clicks          20           0              30°C
Minimum After 20 Down Clicks        0            20             16°C
Middle Value After Mixed Clicks     5            3              24°C
Single Up Click From Default        1            0              23°C
Single Down Click From Default      0            1              21°C

*** Keywords ***
Verify Temperature Boundary
    [Arguments]    ${clicks_up}    ${clicks_down}    ${expected_temp}
    Go To    ${SIMULATOR_URL}
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    ${CLIMATE_SCREEN}    timeout=3s
    FOR    ${i}    IN RANGE    ${clicks_up}
        Click Button    ${TEMP_UP_BTN}
    END
    FOR    ${i}    IN RANGE    ${clicks_down}
        Click Button    ${TEMP_DOWN_BTN}
    END
    Driver Temperature Should Be    ${expected_temp}
