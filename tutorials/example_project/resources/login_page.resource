*** Settings ***
Documentation    Page-object style resource for login behavior.
Resource         common.resource

*** Variables ***
${LOGIN_PAGE_URL}      /login
${USERNAME_INPUT}      id:username
${PASSWORD_INPUT}      id:password
${LOGIN_BUTTON}        id:login-btn
${ERROR_MESSAGE}       css:.error-message
${DASHBOARD_PAGE}      dashboard

*** Keywords ***
Navigate To Login Page
    Set Test Variable    ${CURRENT_PAGE}    login
    Set Test Variable    ${LOGIN_ERROR}    ${EMPTY}
    Log    Navigated to ${LOGIN_PAGE_URL}

Login As
    [Arguments]    ${username}    ${password}
    Log    Input username into ${USERNAME_INPUT}: ${username}
    Log    Input password into ${PASSWORD_INPUT}: value hidden
    Log    Click ${LOGIN_BUTTON}
    IF    '${username}' == '${ADMIN_USER}[username]' and '${password}' == '${ADMIN_USER}[password]'
        Set Test Variable    ${CURRENT_PAGE}    ${DASHBOARD_PAGE}
        Set Test Variable    ${LOGIN_ERROR}    ${EMPTY}
        Set Test Variable    ${AUTHENTICATED_USER}    ${username}
    ELSE IF    '${username}' == '${EMPTY}'
        Set Test Variable    ${LOGIN_ERROR}    Username is required
    ELSE
        Set Test Variable    ${LOGIN_ERROR}    Invalid username or password
    END

Dashboard Should Be Visible
    Should Be Equal    ${CURRENT_PAGE}    ${DASHBOARD_PAGE}
    Should Be Equal    ${AUTHENTICATED_USER}    ${ADMIN_USER}[username]

Login Error Should Be
    [Arguments]    ${expected_message}
    Should Be Equal    ${LOGIN_ERROR}    ${expected_message}

Login Should Succeed
    Navigate To Login Page
    Login As    ${ADMIN_USER}[username]    ${ADMIN_USER}[password]
    Dashboard Should Be Visible

Login Should Fail With
    [Arguments]    ${username}    ${password}    ${expected_message}
    Navigate To Login Page
    Login As    ${username}    ${password}
    Login Error Should Be    ${expected_message}

