*** Settings ***
Documentation    Simulated API session and request helpers.
...              Models HTTP API calls with in-memory state — no real network needed.
...              Used in Tutorial 07 to demonstrate nested API suite organisation.
Resource    ${CURDIR}/common.resource
Variables    ${CURDIR}/../data/environments.py
Variables    ${CURDIR}/../data/users.py

*** Keywords ***
Create Tutorial API Session
    [Documentation]    Simulates creating a RequestsLibrary session for the given environment.
    [Arguments]    ${alias}=tutorial    ${environment}=dev
    ${config}=    Get Environment Config    ${ENVIRONMENTS}    ${environment}
    Set Test Variable    ${API_SESSION_ALIAS}    ${alias}
    Set Test Variable    ${API_BASE_URL}          ${config}[api_url]
    Log    API session '${alias}' → ${API_BASE_URL}

Get Users From Tutorial API
    [Documentation]    Builds a mock /users response using data/users.py fixtures.
    Should Be Equal    ${API_SESSION_ALIAS}    tutorial
    ...    msg=No API session — call 'Create Tutorial API Session' first
    ${first}=    Create Dictionary    id=1    username=${ADMIN_USER}[username]    role=${ADMIN_USER}[role]
    ${second}=   Create Dictionary    id=2    username=${READONLY_USER}[username]  role=${READONLY_USER}[role]
    ${users}=    Create List    ${first}    ${second}
    ${payload}=  Create Dictionary    users=${users}    count=2
    ${response}=    Build Api Response    200    ${payload}
    RETURN    ${response}

Response Status Should Be
    [Arguments]    ${response}    ${expected_status}
    Should Be Equal As Integers    ${response}[status_code]    ${expected_status}
    ...    msg=Response status: expected ${expected_status}, got ${response}[status_code]

Response Should Contain Users
    [Arguments]    ${response}    ${expected_count}=2
    Should Be Equal As Integers    ${response}[payload][count]    ${expected_count}
    Length Should Be    ${response}[payload][users]    ${expected_count}
