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
    Wait Until Element Is Visible    id:climate-temperature-value    timeout=5s
    
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
    Wait Until Element Is Visible    id:media-play-pause-button    timeout=5s
    
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
    Wait Until Element Is Visible    id:settings-theme-toggle    timeout=5s
    
    # Theme Toggle
    ${theme_before}=    Get Element Attribute    id:settings-theme-toggle    data-state
    Click Button    id:settings-theme-toggle
    Capture Page Screenshot
    ${theme_after}=     Get Element Attribute    id:settings-theme-toggle    data-state
    Should Not Be Equal    ${theme_before}    ${theme_after}
    
    # Units Toggle (mapped via UNIT_LABELS)
    Element Text Should Be    id:settings-units-toggle    ${UNIT_LABELS}[metric]
    Click Button    id:settings-units-toggle
    Element Text Should Be    id:settings-units-toggle    ${UNIT_LABELS}[imperial]
    Click Button    id:settings-units-toggle
    Element Text Should Be    id:settings-units-toggle    ${UNIT_LABELS}[metric]
    
    [Teardown]    Go To Home

Settings - Language Mapping Verification
    [Tags]    functional    settings    mapping
    FOR    ${lang}    IN    de    fr    tr    en
        Verify Language Greeting Mapping    ${lang}
    END

Safety Camera - Obstacle Simulation
    [Tags]    functional    camera    mapping
    Navigate To App    camera
    Wait Until Element Is Visible    id:camera-sim-obstacle-near    timeout=5s
    
    # Verify Default State (Clear)
    Element Attribute Value Should Be    id:sensor-rear-left    data-state    clear
    Element Text Should Be               id:sensor-rear-distance    ${OBSTACLE_DISTANCES}[clear]
    
    # Verify all mapped obstacle states (medium -> near -> clear)
    FOR    ${level}    IN    medium    near    clear
        Verify Obstacle Simulation Level    ${level}
        Capture Page Screenshot
    END
    
    [Teardown]    Go To Home

Vehicle Status - Gauges Check
    [Tags]    smoke    vehicle
    Navigate To App    vehicle
    
    Element Should Be Visible    id:vehicle-fuel-value
    Element Should Be Visible    id:vehicle-battery-value
    Element Should Be Visible    id:vehicle-odometer-value
    
    [Teardown]    Go To Home
