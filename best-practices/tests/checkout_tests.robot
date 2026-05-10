*** Settings ***
Resource          ../resources/common/browser.resource
Resource          ../resources/pages/login_page.resource
Resource          ../resources/pages/dashboard_page.resource
Resource          ../resources/pages/checkout_page.resource
Suite Setup       Open Test Browser
Suite Teardown    Close Test Browser
Test Setup        Start Logged In Session

*** Test Cases ***
User Can Complete Checkout
    [Tags]    TC_04_User_can_complete_checkout    Checkout
    Open Checkout
    Complete Checkout    Pro Plan    2
    Order Confirmation Should Be Visible
    Capture Page Screenshot    screenshots/checkout_success.png

User Cannot Checkout Without Terms
    [Tags]    TC_05_User_cannot_checkout_without_terms    Checkout
    Open Checkout
    Submit Checkout Without Terms
    Checkout Terms Error Should Be Visible
    Capture Page Screenshot    screenshots/checkout_error.png

*** Keywords ***
Start Logged In Session
    Reset Demo App State
    Login As Valid User

