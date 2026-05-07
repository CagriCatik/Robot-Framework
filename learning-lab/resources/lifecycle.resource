*** Settings ***
Documentation    Suite and test lifecycle keywords for tutorial suites.
...              Import this alongside common.resource when you want
...              named suite-level startup/teardown hooks.
Resource    ${CURDIR}/common.resource
Library     DateTime

*** Variables ***
${PROJECT_NAME}    Robot Framework Learning Lab

*** Keywords ***
Start Tutorial Suite
    [Documentation]    Logs the suite start time. Use as Suite Setup.
    ${started_at}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Suite Variable    ${SUITE_STARTED_AT}    ${started_at}
    Log    ${PROJECT_NAME} — suite started at ${SUITE_STARTED_AT}

End Tutorial Suite
    [Documentation]    Logs the suite finish. Use as Suite Teardown.
    Log    ${PROJECT_NAME} — suite finished. Started at ${SUITE_STARTED_AT}

Start Tutorial Test
    [Documentation]    Logs the test name. Use as Test Setup.
    Log    Starting: ${TEST NAME}

End Tutorial Test
    [Documentation]    Logs the test outcome. Use as Test Teardown.
    Log    Finished: ${TEST NAME} — ${TEST STATUS}

Prepare Tutorial State
    [Documentation]    Creates a fresh state dictionary and stores it as a test variable.
    ${state}=    Create Dictionary    current_page=home    authenticated=${FALSE}    cart_total=0
    Set Test Variable    ${TUTORIAL_STATE}    ${state}
