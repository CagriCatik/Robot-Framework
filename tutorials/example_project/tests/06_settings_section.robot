*** Settings ***
Documentation     Section 06 showing realistic suite settings, metadata, setup, teardown, tags, and templates.
Metadata          Product       Infotainment Simulator
Metadata          Feature       App Navigation
Resource          ../resources/simulator_ui.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-06    settings    navigation
Test Timeout      1 minute
Test Template     App Icon Should Open Expected Screen

*** Test Cases ***       APP_NAME
Navigation App           navigation
Media App                media
Climate App              climate
Settings App             settings
Camera App               camera

*** Keywords ***
App Icon Should Open Expected Screen
    [Arguments]    ${app_name}
    Open Simulator App    ${app_name}
    Current Simulator Screen Should Be    ${app_name}

