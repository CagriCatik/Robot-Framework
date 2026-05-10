*** Settings ***
Resource    ../common/browser.resource

*** Variables ***
${USERS_TITLE}          css:[data-testid="users-title"]
${USER_NAME}            css:[data-testid="user-name"]
${USER_EMAIL}           css:[data-testid="user-email"]
${USER_ROLE}            css:[data-testid="user-role"]
${USER_SUBMIT}          css:[data-testid="user-submit"]
${USER_FORM_ERROR}      css:[data-testid="user-form-error"]
${USER_SUCCESS}         css:[data-testid="user-success"]
${USER_SEARCH}          css:[data-testid="user-search"]
${USER_SEARCH_SUBMIT}   css:[data-testid="user-search-submit"]
${USER_TABLE}           css:[data-testid="user-table"]

*** Keywords ***
User Management Should Be Visible
    Wait Until Element Is Visible    ${USERS_TITLE}    timeout=5s
    Wait Until Element Is Visible    ${USER_TABLE}    timeout=5s

Create User
    [Arguments]    ${name}    ${email}    ${role}
    Fill User Form    ${name}    ${email}    ${role}
    Submit User Form
    Success Message Should Be    Benutzer wurde gespeichert.

Fill User Form
    [Arguments]    ${name}    ${email}    ${role}
    Input Text    ${USER_NAME}    ${name}
    Input Text    ${USER_EMAIL}    ${email}
    Select From List By Label    ${USER_ROLE}    ${role}

Submit User Form
    Click Button    ${USER_SUBMIT}

Success Message Should Be
    [Arguments]    ${message}
    Wait Until Element Is Visible    ${USER_SUCCESS}    timeout=5s
    Element Text Should Be    ${USER_SUCCESS}    ${message}

User Form Error Should Be Visible
    Wait Until Element Is Visible    ${USER_FORM_ERROR}    timeout=5s
    Element Text Should Be    ${USER_FORM_ERROR}    Name und E-Mail sind Pflichtfelder.

Search User
    [Arguments]    ${term}
    Input Text    ${USER_SEARCH}    ${term}
    Click Button    ${USER_SEARCH_SUBMIT}

User Row Should Be Visible
    [Arguments]    ${name}
    Wait Until Page Contains Element    xpath://tr[td[normalize-space(.)="${name}"]]    timeout=5s

User Row Should Not Be Visible
    [Arguments]    ${name}
    Page Should Not Contain Element    xpath://tr[td[normalize-space(.)="${name}"]]

Open Edit Form For User
    [Arguments]    ${name}
    Click Button    xpath://tr[td[normalize-space(.)="${name}"]]//button[normalize-space(.)="Bearbeiten"]
    Wait Until Element Is Visible    css:[data-testid="user-cancel-edit"]    timeout=5s

Change User Name To
    [Arguments]    ${name}
    Clear Element Text    ${USER_NAME}
    Input Text    ${USER_NAME}    ${name}

Delete User
    [Arguments]    ${name}
    Click Button    xpath://tr[td[normalize-space(.)="${name}"]]//button[normalize-space(.)="Loeschen"]
    Success Message Should Be    Benutzer wurde geloescht.

