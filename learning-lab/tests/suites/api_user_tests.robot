*** Settings ***
Documentation    Tutorial 07 — Nested API suite example.
...              Demonstrates that non-browser tests live alongside browser tests
...              in the same project and run under the same robot command.

Resource    ${CURDIR}/../../resources/api_helpers.resource

Test Tags    api    nested    tutorial-07

*** Test Cases ***
API Session Can Be Created For Dev Environment
    [Tags]    smoke
    Create Tutorial API Session
    Should Not Be Empty    ${API_SESSION_ALIAS}
    Should Not Be Empty    ${API_BASE_URL}

Get Users Returns Two Records
    [Tags]    smoke
    Create Tutorial API Session
    ${response}=    Get Users From Tutorial API
    Response Status Should Be    ${response}    200
    Response Should Contain Users    ${response}    2

Admin User Is Included In Response
    Create Tutorial API Session
    ${response}=    Get Users From Tutorial API
    ${users}=    Set Variable    ${response}[payload][users]
    ${names}=    Evaluate    [u['username'] for u in $users]
    Should Contain    ${names}    admin
