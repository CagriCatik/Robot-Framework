*** Settings ***
Resource          ../resources/common/browser.resource
Resource          ../resources/common/test_data.resource
Resource          ../resources/pages/login_page.resource
Resource          ../resources/pages/dashboard_page.resource
Suite Setup       Open Test Browser
Suite Teardown    Close Test Browser
Test Setup        Reset Demo App State

*** Test Cases ***
User Can Login With Valid Credentials
    [Tags]    TC_01_User_can_login_with_valid_credentials    Login
    Open Login Page
    Login With Credentials    ${VALID_USER_EMAIL}    ${VALID_USER_PASSWORD}
    Dashboard Should Be Visible
    Capture Page Screenshot    screenshots/login_success.png

Login Fails With Invalid Password
    [Tags]    TC_02_Login_fails_with_invalid_password    Login
    Open Login Page
    Login With Credentials    ${VALID_USER_EMAIL}    ${INVALID_PASSWORD}
    Login Error Should Be Visible
    Capture Page Screenshot    screenshots/login_error.png

User Can Request Password Reset
    [Tags]    TC_03_User_can_request_password_reset    Login
    Open Password Reset Page
    Request Password Reset For    ${VALID_USER_EMAIL}
    Password Reset Confirmation Should Be Visible
    Capture Page Screenshot    screenshots/password_reset.png

