*** Settings ***
Documentation     Section 12 showing maintainable, business-level simulator tests.
Resource          ../resources/media_page.resource
Resource          ../resources/climate_page.resource
Resource          ../resources/camera_page.resource
Resource          ../resources/vehicle_page.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-12    best-practices

*** Test Cases ***
Smoke Test Covers Driver-Critical Information Without Low-Level Noise
    [Tags]    smoke    vehicle
    Open Vehicle Screen
    Vehicle Gauges Should Be Visible
    Fuel Percentage Should Be Plausible

Functional Test Uses Page Keywords Instead Of Raw Selectors
    [Tags]    functional    climate
    Open Climate Screen
    Driver Temperature Should Increase
    Driver Seat Heat Should Cycle

Data Driven Navigation Keeps Coverage Compact
    [Tags]    data-driven
    [Template]    Driver App Should Be Reachable
    media
    climate
    camera
    vehicle

Risk-Based Camera Test Verifies A Safety-Relevant State
    [Tags]    safety    camera
    Open Camera Screen
    Near Obstacle Should Update Rear Sensors

*** Keywords ***
Driver App Should Be Reachable
    [Arguments]    ${app_name}
    Open Simulator App    ${app_name}
    Current Simulator Screen Should Be    ${app_name}
    Go To Home Screen

