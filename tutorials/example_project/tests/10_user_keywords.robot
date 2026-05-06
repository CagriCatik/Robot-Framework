*** Settings ***
Documentation     Section 10 with user keywords that operate on real simulator pages.
Resource          ../resources/climate_page.resource
Resource          ../resources/media_page.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-10    user-keywords

*** Test Cases ***
Keyword Arguments Open Any Supported App
    [Tags]    smoke
    Open App And Verify Screen    media
    Go To Home Screen
    Open App And Verify Screen    climate

Keyword Returns Real UI State
    Open Media Screen
    ${state}=    Toggle Playback And Return State
    Should Be Equal    ${state}    paused

Variable Length Arguments Validate Multiple Apps
    Verify Apps Are Reachable    navigation    media    climate    settings

Expected UI Failure Can Be Handled Without Hiding Defects
    ${present}=    Optional Element Should Be Present    id:not-a-real-control
    Should Not Be True    ${present}

Keyword Teardown Captures Evidence
    Open Climate And Capture Evidence

*** Keywords ***
Open App And Verify Screen
    [Arguments]    ${app_name}
    Open Simulator App    ${app_name}
    Current Simulator Screen Should Be    ${app_name}

Verify Apps Are Reachable
    [Arguments]    @{app_names}
    FOR    ${app_name}    IN    @{app_names}
        Open App And Verify Screen    ${app_name}
        Go To Home Screen
    END

Optional Element Should Be Present
    [Arguments]    ${locator}
    ${present}=    Run Keyword And Return Status    Element Should Be Visible    ${locator}
    RETURN    ${present}

Open Climate And Capture Evidence
    [Teardown]    Capture Evidence Screenshot    keyword-teardown-climate
    Open Climate Screen
    Driver Temperature Should Increase

