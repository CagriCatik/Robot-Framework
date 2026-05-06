*** Settings ***
Documentation    Shared imports, variables, and helper keywords for tutorial suites.
Library          Collections
Library          DateTime
Library          OperatingSystem
Library          String
Library          ${CURDIR}/../libraries/LearningTools.py
Variables        ${CURDIR}/../data/environments.py
Variables        ${CURDIR}/../data/users.py

*** Variables ***
${PROJECT_NAME}          Robot Framework Tutorial Example Project
${DEFAULT_ENVIRONMENT}   dev
@{CORE_APPS}             navigation    media    climate    settings    camera
&{DEFAULT_SESSION}       alias=tutorial    status=created

*** Keywords ***
Log Section
    [Arguments]    ${section_name}
    Log    Running tutorial section: ${section_name}

Get Tutorial Environment
    [Arguments]    ${name}=${DEFAULT_ENVIRONMENT}
    ${environment}=    Get Environment Config    ${ENVIRONMENTS}    ${name}
    RETURN    ${environment}

Environment Should Have Required Keys
    [Arguments]    ${name}=${DEFAULT_ENVIRONMENT}
    ${environment}=    Get Tutorial Environment    ${name}
    Required Keys Should Exist    ${environment}    base_url    api_url    browser    timeout

App Name Should Be Known
    Should Be Equal    ${PROJECT_NAME}    Robot Framework Tutorial Example Project

Normalize Screen Name
    [Arguments]    ${screen_name}
    ${label}=    Normalize Label    ${screen_name}
    RETURN    ${label}

Create Tutorial State
    ${state}=    Create Dictionary    current_page=home    authenticated=${FALSE}    cart_total=0
    RETURN    ${state}

State Page Should Be
    [Arguments]    ${state}    ${expected_page}
    Should Be Equal    ${state}[current_page]    ${expected_page}

