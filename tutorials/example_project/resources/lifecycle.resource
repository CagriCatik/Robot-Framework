*** Settings ***
Documentation    Suite and test lifecycle keywords.
Resource         common.resource

*** Keywords ***
Start Tutorial Suite
    ${started_at}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Suite Variable    ${TUTORIAL_SUITE_STARTED_AT}    ${started_at}
    Log    ${PROJECT_NAME} started at ${TUTORIAL_SUITE_STARTED_AT}

End Tutorial Suite
    Log    ${PROJECT_NAME} finished. Started at ${TUTORIAL_SUITE_STARTED_AT}

Start Tutorial Test
    Log    Starting test: ${TEST NAME}

End Tutorial Test
    Log    Finished test: ${TEST NAME} with ${TEST STATUS}

Prepare Tutorial Case
    ${state}=    Create Tutorial State
    Set Test Variable    ${TUTORIAL_STATE}    ${state}

Cleanup Tutorial Case
    Log    Cleaning test state for ${TEST NAME}

