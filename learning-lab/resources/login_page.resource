*** Settings ***
Documentation    Simulated login page keywords.
...              Models the login flow entirely with state variables — no browser needed.
...              Used in Tutorial 07 data-driven examples and Tutorial 12 best-practices.
Resource    ${CURDIR}/common.resource
Variables    ${CURDIR}/../data/users.py

*** Variables ***
${LOGIN_PAGE_URL}    /login
${USERNAME_INPUT}    id:username
${PASSWORD_INPUT}    id:password
${LOGIN_BUTTON}      id:login-btn
${ERROR_MESSAGE}     css:.error-message
${DASHBOARD_PAGE}    dashboard

*** Keywords ***
Navigate To Login Page
    Set Test Variable    ${CURRENT_PAGE}    login
    Set Test Variable    ${LOGIN_ERROR}    ${EMPTY}
    Log    Navigated to ${LOGIN_PAGE_URL}

Login As
    [Documentation]    Simulates a login attempt. Sets CURRENT_PAGE and LOGIN_ERROR variables.
    [Arguments]    ${username}    ${password}
    Log    Input username: ${username}
    Log    Input password: (hidden)
    IF    '${username}' == '${ADMIN_USER}[username]' and '${password}' == '${ADMIN_USER}[password]'
        Set Test Variable    ${CURRENT_PAGE}             ${DASHBOARD_PAGE}
        Set Test Variable    ${LOGIN_ERROR}              ${EMPTY}
        Set Test Variable    ${AUTHENTICATED_USER}       ${username}
    ELSE IF    '${username}' == '${EMPTY}'
        Set Test Variable    ${LOGIN_ERROR}    Username is required
    ELSE
        Set Test Variable    ${LOGIN_ERROR}    Invalid username or password
    END

Dashboard Should Be Visible
    Should Be Equal    ${CURRENT_PAGE}    ${DASHBOARD_PAGE}
    ...    msg=Expected dashboard page but current page is '${CURRENT_PAGE}'

Login Error Should Be
    [Arguments]    ${expected_message}
    Should Be Equal    ${LOGIN_ERROR}    ${expected_message}
    ...    msg=Login error: expected '${expected_message}', got '${LOGIN_ERROR}'

Login Should Succeed
    Navigate To Login Page
    Login As    ${ADMIN_USER}[username]    ${ADMIN_USER}[password]
    Dashboard Should Be Visible

Login Should Fail With
    [Documentation]    Convenience keyword for data-driven login failure tests.
    [Arguments]    ${username}    ${password}    ${expected_message}
    Navigate To Login Page
    Login As    ${username}    ${password}
    Login Error Should Be    ${expected_message}
