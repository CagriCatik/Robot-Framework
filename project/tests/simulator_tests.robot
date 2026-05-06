*** Settings ***
Documentation     Comprehensive functional tests for the Center Information Infotainment Simulator.
Resource          ../resources/simulator.resource
Suite Setup       Open Center Information Simulator
Suite Teardown    Close All Browsers

*** Test Cases ***
Verify System Boot and Home Screen
    [Tags]    smoke    system
    Verify Status Bar Information
    Element Should Be Visible    id:app-icon-navigation
    Element Should Be Visible    id:app-icon-media
    Element Should Be Visible    id:app-icon-climate
    Element Text Should Be       id:nav-current-screen    HOME

Climate Control - Temperature and Seat Heat
    [Tags]    functional    climate
    Navigate To App    climate
    Sleep    1s
    
    # Test Temperature Adjustment
    ${initial_temp}=    Get Text    id:climate-temperature-value
    Click Button    id:climate-temp-up
    ${new_temp}=      Get Text    id:climate-temperature-value
    Should Not Be Equal    ${initial_temp}    ${new_temp}
    
    # Test Seat Heat Cycling (OFF -> LOW -> HIGH -> OFF)
    Element Attribute Value Should Be    id:climate-driver-seat-heat    data-state    off
    Click Button    id:climate-driver-seat-heat
    Capture Page Screenshot
    Element Attribute Value Should Be    id:climate-driver-seat-heat    data-state    low
    Click Button    id:climate-driver-seat-heat
    Capture Page Screenshot
    Element Attribute Value Should Be    id:climate-driver-seat-heat    data-state    high
    Click Button    id:climate-driver-seat-heat
    Capture Page Screenshot
    Element Attribute Value Should Be    id:climate-driver-seat-heat    data-state    off
    
    [Teardown]    Go To Home

Media Player - Controls and Volume
    [Tags]    functional    media
    Navigate To App    media
    Sleep    1s
    
    # Toggle Playback
    ${state}=    Toggle Media Playback
    Should Be Equal    ${state}    paused
    ${state}=    Toggle Media Playback
    Should Be Equal    ${state}    playing
    
    # Volume Control
    ${vol_before}=    Get Text    id:media-volume-value
    Click Button    id:media-volume-up
    ${vol_after}=     Get Text    id:media-volume-value
    Should Be True    ${vol_after} > ${vol_before}
    
    [Teardown]    Go To Home

Settings - Theme and Units Toggle
    [Tags]    functional    settings
    Navigate To App    settings
    Sleep    1s
    
    # Theme Toggle
    ${theme_before}=    Get Element Attribute    id:settings-theme-toggle    data-state
    Click Button    id:settings-theme-toggle
    Capture Page Screenshot
    ${theme_after}=     Get Element Attribute    id:settings-theme-toggle    data-state
    Should Not Be Equal    ${theme_before}    ${theme_after}
    
    # Units Toggle
    Element Text Should Be    id:settings-units-toggle    Metric
    Click Button    id:settings-units-toggle
    Element Text Should Be    id:settings-units-toggle    Imperial
    
    [Teardown]    Go To Home

Safety Camera - Obstacle Simulation
    [Tags]    functional    camera
    Navigate To App    camera
    Sleep    1s
    
    # Verify Default State (Clear)
    Element Attribute Value Should Be    id:sensor-rear-left    data-state    clear
    Element Text Should Be               id:sensor-rear-distance    Clear
    
    # simulate near obstacle
    Click Button    id:camera-sim-obstacle-near
    Capture Page Screenshot
    Element Attribute Value Should Be    id:sensor-rear-left    data-state    near
    Element Text Should Be               id:sensor-rear-distance    < 0.3 m
    
    # Clear Simulation
    Click Button    id:camera-sim-obstacle-clear
    Element Attribute Value Should Be    id:sensor-rear-left    data-state    clear
    
    [Teardown]    Go To Home

Vehicle Status - Gauges Check
    [Tags]    smoke    vehicle
    Navigate To App    vehicle
    
    Element Should Be Visible    id:vehicle-fuel-value
    Element Should Be Visible    id:vehicle-battery-value
    Element Should Be Visible    id:vehicle-odometer-value
    
    [Teardown]    Go To Home
