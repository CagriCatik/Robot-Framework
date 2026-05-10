*** Settings ***
Resource    ../common/browser.resource
Resource    ../common/test_data.resource

*** Variables ***
${LOGIN_EMAIL}                   css:[data-testid="login-email"]
${LOGIN_PASSWORD}                css:[data-testid="login-password"]
${LOGIN_SUBMIT}                  css:[data-testid="login-submit"]
${LOGIN_ERROR}                   css:[data-testid="login-error"]
${FORGOT_PASSWORD_LINK}          css:[data-testid="forgot-password-link"]
${PASSWORD_RESET_EMAIL}          css:[data-testid="password-reset-email"]
${PASSWORD_RESET_SUBMIT}         css:[data-testid="password-reset-submit"]
${PASSWORD_RESET_CONFIRMATION}   css:[data-testid="password-reset-confirmation"]

*** Keywords ***
Open Login Page
    Go To App Route    login
    Wait Until Element Is Visible    ${LOGIN_EMAIL}    timeout=5s

Login With Credentials
    [Arguments]    ${email}    ${password}
    Wait Until Element Is Visible    ${LOGIN_EMAIL}    timeout=5s
    Input Text    ${LOGIN_EMAIL}    ${email}
    Input Text    ${LOGIN_PASSWORD}    ${password}
    Click Button    ${LOGIN_SUBMIT}

Login As Valid User
    Open Login Page
    Login With Credentials    ${VALID_USER_EMAIL}    ${VALID_USER_PASSWORD}
    Wait Until Element Is Visible    css:[data-testid="dashboard-title"]    timeout=5s

Login Error Should Be Visible
    Wait Until Element Is Visible    ${LOGIN_ERROR}    timeout=5s
    Element Text Should Be    ${LOGIN_ERROR}    E-Mail oder Passwort ist falsch.

Open Password Reset Page
    Open Login Page
    Click Button    ${FORGOT_PASSWORD_LINK}
    Wait Until Element Is Visible    ${PASSWORD_RESET_EMAIL}    timeout=5s

Request Password Reset For
    [Arguments]    ${email}
    Input Text    ${PASSWORD_RESET_EMAIL}    ${email}
    Click Button    ${PASSWORD_RESET_SUBMIT}

Password Reset Confirmation Should Be Visible
    Wait Until Element Is Visible    ${PASSWORD_RESET_CONFIRMATION}    timeout=5s
    Element Text Should Be    ${PASSWORD_RESET_CONFIRMATION}    Reset-Link wurde versendet.

