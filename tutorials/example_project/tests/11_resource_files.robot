*** Settings ***
Documentation     Section 11 proving that realistic page resources keep tests readable.
Resource          ../resources/media_page.resource
Resource          ../resources/climate_page.resource
Resource          ../resources/settings_page.resource
Resource          ../resources/camera_page.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-11    resource-files

*** Test Cases ***
Media Resource Encapsulates Player Interactions
    [Tags]    smoke    media
    Open Media Screen
    Media Volume Should Increase
    Bluetooth Source Can Be Selected

Climate Resource Encapsulates HVAC Interactions
    [Tags]    climate
    Open Climate Screen
    Driver Temperature Should Increase
    AC Toggle Should Change State

Settings Resource Encapsulates Preferences
    [Tags]    settings
    Open Settings Screen
    Theme Toggle Should Change State

Camera Resource Encapsulates Safety Sensor Behavior
    [Tags]    camera
    Open Camera Screen
    Camera View Can Switch To Front
    Go To Home Screen
    Open Camera Screen
    Near Obstacle Should Update Rear Sensors

