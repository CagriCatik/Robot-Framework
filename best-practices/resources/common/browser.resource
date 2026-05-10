*** Settings ***
Library     SeleniumLibrary    timeout=5s    implicit_wait=0s

*** Variables ***
${BASE_URL}          http://127.0.0.1:8010
${BROWSER}           chrome
${SELENIUM_SPEED}    0.5s

*** Keywords ***
Open Test Browser
    Set Selenium Speed    ${SELENIUM_SPEED}
    Open Browser    ${BASE_URL}    ${BROWSER}
    Set Window Size    1366    900
    Register Keyword To Run On Failure    Capture Page Screenshot

Close Test Browser
    Close All Browsers

Reset Demo App State
    Go To    ${BASE_URL}/#/login
    Execute Javascript    window.localStorage.removeItem('bp_demo_session'); window.localStorage.removeItem('bp_demo_users'); window.localStorage.removeItem('bp_demo_orders');
    Reload Page
    Wait Until Element Is Visible    css:[data-testid="login-email"]    timeout=5s

Go To App Route
    [Arguments]    ${route}
    Go To    ${BASE_URL}/#/${route}

