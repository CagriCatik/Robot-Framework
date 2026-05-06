*** Settings ***
Documentation     Section 07 with realistic test case settings, tags, and data-driven UI cases.
Resource          ../resources/media_page.resource
Resource          ../resources/settings_page.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-07    suites-and-cases

*** Test Cases ***
Media Player Can Pause And Resume
    [Documentation]    Verifies media playback controls using real UI state.
    [Tags]             smoke    media
    [Timeout]          45 seconds
    Open Media Screen
    ${state}=    Toggle Playback And Return State
    Should Be Equal    ${state}    paused
    ${state}=    Toggle Playback And Return State
    Should Be Equal    ${state}    playing

Settings Controls Can Be Exercised With A Template
    [Tags]    data-driven    settings
    [Template]    Settings Control Should Work
    theme
    units
    brightness

Taggable Regression Case Covers Media Source Selection
    [Tags]    regression    media
    Open Media Screen
    Bluetooth Source Can Be Selected

*** Keywords ***
Settings Control Should Work
    [Arguments]    ${control_name}
    Open Settings Screen
    IF    '${control_name}' == 'theme'
        Theme Toggle Should Change State
    ELSE IF    '${control_name}' == 'units'
        Units Toggle Should Switch To Imperial
    ELSE IF    '${control_name}' == 'brightness'
        Brightness Should Increase
    END
    Go To Home Screen

