*** Settings ***
Documentation    Real browser automation helpers for the infotainment simulator.
Library          SeleniumLibrary
Resource         common.resource

*** Variables ***
${BROWSER_NAME}            chrome
${HEADLESS}                %{TUTORIAL_HEADLESS=true}
${SCREENSHOT_SUBDIR}       tutorial_screenshots

*** Keywords ***
Open Tutorial Simulator
    [Arguments]    ${headless}=${HEADLESS}
    ${simulator_path}=    Normalize Path    ${CURDIR}/../../../simulator/index.html
    File Should Exist    ${simulator_path}
    ${simulator_url}=    Get File Uri    ${simulator_path}
    Set Suite Variable    ${SIMULATOR_PATH}    ${simulator_path}
    Set Suite Variable    ${SIMULATOR_URL}     ${simulator_url}
    Set Screenshot Directory    ${OUTPUT DIR}/${SCREENSHOT_SUBDIR}
    IF    '${headless}'.lower() in ['true', '1', 'yes']
        ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    modules=sys,selenium.webdriver
        ${headless_arg}=    Set Variable    --headless=new
        ${window_size_arg}=    Set Variable    --window-size=1440,1000
        Call Method    ${options}    add_argument    ${headless_arg}
        Call Method    ${options}    add_argument    ${window_size_arg}
        Create Webdriver    Chrome    options=${options}
        Go To    ${simulator_url}
    ELSE
        Open Browser    ${simulator_url}    ${BROWSER_NAME}
        Maximize Browser Window
    END
    Set Selenium Timeout    8s
    Wait Until Element Is Visible    id:screen-home
    Element Text Should Be    id:nav-current-screen    HOME

Close Tutorial Simulator
    Close All Browsers

Go To Home Screen
    Click Button    id:nav-home-button
    Wait Until Element Is Visible    id:screen-home
    Element Text Should Be    id:nav-current-screen    HOME

Open Simulator App
    [Arguments]    ${app_name}
    ${app_id}=    Convert To Lower Case    ${app_name}
    Click Button    id:app-icon-${app_id}
    Wait Until Element Is Visible    id:screen-${app_id}
    ${expected_title}=    Convert To Upper Case    ${app_name}
    Element Text Should Be    id:nav-current-screen    ${expected_title}

Current Simulator Screen Should Be
    [Arguments]    ${screen_name}
    ${expected_title}=    Convert To Upper Case    ${screen_name}
    Element Text Should Be    id:nav-current-screen    ${expected_title}

Status Bar Should Be Complete
    Element Should Be Visible    id:status-time
    Element Should Be Visible    id:status-outdoor-temp
    Element Should Be Visible    id:status-wifi
    Element Should Be Visible    id:status-bluetooth
    Element Should Be Visible    id:status-fuel

Home Screen App Icons Should Be Visible
    FOR    ${app}    IN    navigation    media    climate    phone    vehicle    settings    camera
        Element Should Be Visible    id:app-icon-${app}
    END

Element Numeric Text Should Increase After Click
    [Arguments]    ${value_locator}    ${button_locator}
    ${before_text}=    Get Text    ${value_locator}
    ${before}=    Parse Number    ${before_text}
    Click Button    ${button_locator}
    ${after_text}=    Get Text    ${value_locator}
    ${after}=    Parse Number    ${after_text}
    Should Be True    ${after} > ${before}
    RETURN    ${before}    ${after}

Element Data State Should Change After Click
    [Arguments]    ${locator}
    ${before}=    Get Element Attribute    ${locator}    data-state
    Click Button    ${locator}
    ${after}=    Get Element Attribute    ${locator}    data-state
    Should Not Be Equal    ${before}    ${after}
    RETURN    ${before}    ${after}

Capture Evidence Screenshot
    [Arguments]    ${name}
    Capture Page Screenshot    ${name}.png
