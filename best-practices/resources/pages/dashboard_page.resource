*** Settings ***
Resource    ../common/browser.resource

*** Variables ***
${DASHBOARD_TITLE}    css:[data-testid="dashboard-title"]
${NAV_USERS}          css:[data-testid="nav-users"]
${NAV_CHECKOUT}       css:[data-testid="nav-checkout"]

*** Keywords ***
Dashboard Should Be Visible
    Wait Until Element Is Visible    ${DASHBOARD_TITLE}    timeout=5s
    Element Text Should Be    ${DASHBOARD_TITLE}    Dashboard

Open User Management
    Wait Until Element Is Visible    ${NAV_USERS}    timeout=5s
    Click Button    ${NAV_USERS}
    Wait Until Element Is Visible    css:[data-testid="users-title"]    timeout=5s

Open Checkout
    Wait Until Element Is Visible    ${NAV_CHECKOUT}    timeout=5s
    Click Button    ${NAV_CHECKOUT}
    Wait Until Element Is Visible    css:[data-testid="checkout-title"]    timeout=5s

