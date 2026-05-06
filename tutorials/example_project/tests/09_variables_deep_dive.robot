*** Settings ***
Documentation     Section 09 using variables for real locators, data, built-ins, and environment config.
Resource          ../resources/climate_page.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-09    variables

*** Variables ***
${CLIMATE_APP_NAME}          climate
@{HVAC_CONTROLS}             temperature    seat_heat    ac
&{CLIMATE_EXPECTATIONS}      default_screen=CLIMATE    min_controls=3
${OPTIONAL_ENVIRONMENT}      %{TUTORIAL_ENV=dev}

*** Test Cases ***
Scalar List And Dictionary Variables Drive A Real Screen
    [Tags]    smoke
    Open Simulator App    ${CLIMATE_APP_NAME}
    Element Text Should Be    id:nav-current-screen    ${CLIMATE_EXPECTATIONS}[default_screen]
    Length Should Be    ${HVAC_CONTROLS}    ${CLIMATE_EXPECTATIONS}[min_controls]

Built In Variables Are Useful For Diagnostics
    Log    Test: ${TEST NAME}
    Log    Suite: ${SUITE NAME}
    Log    Current file directory: ${CURDIR}
    Log    Results directory: ${OUTPUT DIR}
    Should Not Be Empty    ${OUTPUT DIR}

Environment Variables Select Test Configuration
    ${environment}=    Get Tutorial Environment    ${OPTIONAL_ENVIRONMENT}
    Required Keys Should Exist    ${environment}    base_url    api_url    browser    timeout

Runtime Variables Store UI Measurements
    Open Climate Screen
    ${before_text}=    Get Text    ${DRIVER_TEMP_VALUE}
    ${before}=    Parse Number    ${before_text}
    Click Button    ${DRIVER_TEMP_UP_BUTTON}
    ${after_text}=    Get Text    ${DRIVER_TEMP_VALUE}
    ${after}=    Parse Number    ${after_text}
    Should Be True    ${after} > ${before}

