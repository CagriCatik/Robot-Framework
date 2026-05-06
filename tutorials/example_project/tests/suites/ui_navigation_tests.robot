*** Settings ***
Documentation     Nested UI suite example showing folder-based suite organization.
Resource          ../../resources/navigation_page.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         ui    nested

*** Test Cases ***
Nested UI Suite Exercises A Real Navigation Screen
    [Tags]    smoke
    Open Navigation Screen
    Current Simulator Screen Should Be    navigation

Nested UI Suite Exercises A Real Phone Control
    [Tags]    phone
    Open Phone Screen
    Phone Bluetooth Toggle Should Change State
