*** Settings ***
Documentation     Section 05 showing a complete Robot suite against a real screen.
Metadata          Feature    Vehicle status dashboard
Resource          ../resources/vehicle_page.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-05    project-anatomy    vehicle

*** Variables ***
${FEATURE_NAME}       Vehicle Status
@{REQUIRED_GAUGES}    fuel    battery    odometer    tire pressure

*** Test Cases ***
Vehicle Status Screen Exposes Critical Driver Information
    [Documentation]    Demonstrates settings, variables, test cases, and keywords in a realistic file.
    [Tags]             smoke
    Open Vehicle Screen
    Vehicle Gauges Should Be Visible
    Fuel Percentage Should Be Plausible
    Required Gauge List Should Be Complete

Continuation Lines Keep Longer Business Checks Readable
    Open Vehicle Screen
    Log Gauge Expectations
    ...    ${FEATURE_NAME}
    ...    fuel
    ...    battery
    ...    odometer
    ...    tire pressure

*** Keywords ***
Required Gauge List Should Be Complete
    Length Should Be    ${REQUIRED_GAUGES}    4
    List Should Contain Value    ${REQUIRED_GAUGES}    fuel
    List Should Contain Value    ${REQUIRED_GAUGES}    tire pressure

Log Gauge Expectations
    [Arguments]    ${feature_name}    @{gauges}
    FOR    ${gauge}    IN    @{gauges}
        Log    ${feature_name} must show ${gauge}.
    END

