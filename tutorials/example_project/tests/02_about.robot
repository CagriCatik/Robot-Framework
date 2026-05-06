*** Settings ***
Documentation     Section 02 with real standard-library, custom-library, UI, and API-style examples.
Resource          ../resources/media_page.resource
Resource          ../resources/api_helpers.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-02    about    simulator

*** Test Cases ***
Standard Libraries Help Inspect Real UI Data
    [Tags]    smoke    standard-libraries
    Home Screen App Icons Should Be Visible
    ${apps}=    Create List    navigation    media    climate    settings
    Append To List    ${apps}    camera
    Length Should Be    ${apps}    5
    ${label}=    Normalize Screen Name    climate control
    Should Be Equal    ${label}    Climate Control

External Library Drives A Real Browser Screen
    [Tags]    selenium    media
    Open Media Screen
    ${state}=    Toggle Playback And Return State
    Should Be Equal    ${state}    paused
    Media Volume Should Increase

Custom Python Library Supports Project-Specific Checks
    [Tags]    custom-library
    ${slug}=    Slugify    Rear Camera View
    Should Be Equal    ${slug}    rear-camera-view
    ${number}=    Parse Number    Volume: 42%
    Should Be Equal As Integers    ${number}    42

API-Style Resource Models A Backend Contract
    [Tags]    api
    Create Tutorial API Session
    ${response}=    Get Users From Tutorial API
    Response Status Should Be    ${response}    200
    Response Should Contain Users    ${response}    2

