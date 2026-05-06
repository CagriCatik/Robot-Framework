*** Settings ***
Documentation     Section 04 using portable paths, output folders, and real simulator configuration.
Resource          ../resources/simulator_ui.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-04    configuration

*** Test Cases ***
Project Folders Required By The Automation Suite Exist
    [Tags]    smoke
    Directory Should Exist    ${CURDIR}/../resources
    Directory Should Exist    ${CURDIR}/../libraries
    Directory Should Exist    ${CURDIR}/../data
    Directory Should Exist    ${CURDIR}/../results

Curdir Based Simulator Path Works From This Suite
    File Should Exist    ${SIMULATOR_PATH}
    Should Start With    ${SIMULATOR_URL}    file:///
    Current Simulator Screen Should Be    home

Output Directory Is Ready For Screenshots And Reports
    Should Not Be Empty    ${OUTPUT DIR}
    Capture Evidence Screenshot    configuration-home
    File Should Exist    ${OUTPUT DIR}/${SCREENSHOT_SUBDIR}/configuration-home.png

Environment Data Can Configure Different Test Runs
    ${dev}=    Get Tutorial Environment    dev
    ${staging}=    Get Tutorial Environment    staging
    Should Not Be Equal    ${dev}[base_url]    ${staging}[base_url]

