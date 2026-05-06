*** Settings ***
Documentation    Simulated API helper resource for RequestsLibrary-style practice.
Resource         common.resource

*** Keywords ***
Create Tutorial API Session
    [Arguments]    ${alias}=tutorial    ${environment}=dev
    ${config}=    Get Tutorial Environment    ${environment}
    Set Test Variable    ${API_SESSION_ALIAS}    ${alias}
    Set Test Variable    ${API_BASE_URL}    ${config}[api_url]
    Log    Created API session ${API_SESSION_ALIAS} for ${API_BASE_URL}

Get Users From Tutorial API
    Should Be Equal    ${API_SESSION_ALIAS}    tutorial
    ${first}=    Create Dictionary    id=1    username=${ADMIN_USER}[username]    role=${ADMIN_USER}[role]
    ${second}=    Create Dictionary    id=2    username=${READONLY_USER}[username]    role=${READONLY_USER}[role]
    ${users}=    Create List    ${first}    ${second}
    ${payload}=    Create Dictionary    users=${users}    count=2
    ${response}=    Build Api Response    200    ${payload}
    RETURN    ${response}

Response Status Should Be
    [Arguments]    ${response}    ${expected_status}
    Should Be Equal As Integers    ${response}[status_code]    ${expected_status}

Response Should Contain Users
    [Arguments]    ${response}    ${expected_count}=2
    Should Be Equal As Integers    ${response}[payload][count]    ${expected_count}
    Length Should Be    ${response}[payload][users]    ${expected_count}

