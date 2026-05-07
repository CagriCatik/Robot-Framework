*** Settings ***
Documentation    Tutorial 07 — Test case settings, tags, data-driven templates, dry run.
...              Teaches: [Tags], [Setup], [Teardown], [Timeout], [Template], tag filtering.

Resource         ${CURDIR}/../resources/common.resource

Suite Setup      Open Simulator
Suite Teardown   Close All Browsers
Test Setup       Go To Home Screen

*** Test Cases ***
Climate Screen Is Reachable
    [Documentation]    Smoke check: the climate icon leads to the climate screen.
    [Tags]    smoke    climate    tutorial-07
    [Setup]    Wait Until Element Is Visible    id:screen-home    timeout=5s
    [Teardown]    Go To Home Screen
    [Timeout]    30 seconds
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    Element Text Should Be    id:nav-current-screen    CLIMATE

Media Screen Shows A Track Name
    [Documentation]    The media screen must display a non-empty track name on load.
    [Tags]    smoke    media    tutorial-07
    [Teardown]    Go To Home Screen
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    id:screen-media    timeout=3s
    ${track}=    Get Text    id:media-track-name
    Should Not Be Empty    ${track}

Volume Controls Are Functional
    [Documentation]    Volume up button must change the displayed value.
    [Tags]    regression    media    tutorial-07
    [Teardown]    Go To Home Screen
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    id:screen-media    timeout=3s
    ${before}=    Get Text    id:media-volume-value
    Click Button    id:media-volume-up
    ${after}=     Get Text    id:media-volume-value
    Should Not Be Equal    ${before}    ${after}

Settings Theme Feature Is Working
    [Documentation]    Theme toggle: data-state must change on click.
    [Tags]    regression    settings    tutorial-07
    [Teardown]    Go To Home Screen
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    id:screen-settings    timeout=3s
    ${before}=    Get Element Attribute    id:settings-theme-toggle    data-state
    Click Button    id:settings-theme-toggle
    ${after}=     Get Element Attribute    id:settings-theme-toggle    data-state
    Should Not Be Equal    ${before}    ${after}
    Click Button    id:settings-theme-toggle    # restore

Login Validation Data-Driven
    [Documentation]    Template pattern: same keyword, different data rows, no duplication.
    [Tags]    template    tutorial-07
    [Template]    Screen Opens And Returns To Home
    navigation    NAVIGATION
    media         MEDIA
    climate       CLIMATE
    settings      SETTINGS

*** Keywords ***
Screen Opens And Returns To Home
    [Arguments]    ${app}    ${expected_screen_label}
    Click Button    id:app-icon-${app}
    Wait Until Element Is Visible    id:screen-${app}    timeout=3s
    Element Text Should Be    id:nav-current-screen    ${expected_screen_label}
    Go To Home Screen
