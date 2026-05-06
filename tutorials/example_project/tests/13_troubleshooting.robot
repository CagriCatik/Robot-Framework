*** Settings ***
Documentation     Section 13 with realistic, safe troubleshooting checks against the simulator.
Resource          ../resources/simulator_ui.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-13    troubleshooting

*** Test Cases ***
Bad Locator Can Be Diagnosed Without Failing The Whole Suite
    [Tags]    smoke
    ${found}=    Run Keyword And Return Status    Element Should Be Visible    id:missing-control
    Should Not Be True    ${found}
    Log    Missing locator was handled intentionally for troubleshooting practice.    WARN

Explicit Wait Fixes Timing-Prone UI Checks
    Open Simulator App    media
    Wait Until Element Is Visible    id:media-play-pause-button    timeout=5s
    Element Should Be Visible    id:media-play-pause-button

Wrong Expected Screen Text Produces A Useful Error
    Open Simulator App    settings
    Run Keyword And Expect Error
    ...    *HOME*SETTINGS*
    ...    Element Text Should Be    id:nav-current-screen    HOME

Corrected Assertion Passes After Reading The Failure
    Open Simulator App    settings
    Element Text Should Be    id:nav-current-screen    SETTINGS
