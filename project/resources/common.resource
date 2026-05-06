*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary

*** Variables ***
${BROWSER}      chrome
${GOOGLE_URL}   https://www.google.com
${API_URL}      https://jsonplaceholder.typicode.com

*** Keywords ***
Open Browser To Google
    Open Browser    ${GOOGLE_URL}    ${BROWSER}
    Maximize Browser Window
    Accept Google Cookies
    Title Should Be    Google

Accept Google Cookies
    # Handle the "Alle akzeptieren" / "Accept all" button if it appears
    ${consent_button}=    Set Variable    xpath=//button[contains(., 'Alle akzeptieren') or contains(., 'Accept all') or @id='L2AGLb']
    Run Keyword And Ignore Error    Wait Until Element Is Visible    ${consent_button}    timeout=5s
    Run Keyword And Ignore Error    Click Button    ${consent_button}

Search For Robot Framework
    [Arguments]    ${search_term}
    Wait Until Element Is Visible    name:q    timeout=10s
    Input Text      name:q    ${search_term}
    Press Keys      name:q    ENTER
    Wait Until Page Contains    Robot Framework

Close My Browser
    Close All Browsers
