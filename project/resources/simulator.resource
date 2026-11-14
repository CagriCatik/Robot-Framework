*** Settings ***
Library    SeleniumLibrary
Library    String
Library    DateTime

*** Variables ***
${SIMULATOR_URL}    ${EMPTY}
${BROWSER}          chrome

*** Keywords ***
Open Center Information Simulator
    ${url}=    Set Variable If    '${SIMULATOR_URL}' != ''    ${SIMULATOR_URL}    ${EMPTY}
    IF    '${url}' == ''
        ${url}=    Evaluate    pathlib.Path(r'''${CURDIR}''').resolve().parents[1].joinpath('simulator', 'index.html').as_uri()    modules=pathlib
    END
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    Set Screenshot Directory    ${OUTPUTDIR}/screenshots_${timestamp}
    Open Browser    ${url}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.5s
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Capture Page Screenshot

Go To Home
    Click Button    id:nav-home-button
    Wait Until Element Is Visible    id:screen-home
    Element Text Should Be    id:nav-current-screen    HOME
    Capture Page Screenshot

Navigate To App
    [Arguments]    ${app_name}
    ${id}=    Convert To Lower Case    ${app_name}
    Click Button    id:app-icon-${id}
    Wait Until Element Is Visible    id:screen-${id}
    Element Text Should Be    id:nav-current-screen    ${app_name.upper()}
    Capture Page Screenshot

Set Climate Temperature
    [Arguments]    ${target_temp}
    ${current}=    Get Text    id:climate-temperature-value
    Log    Setting temperature to ${target_temp} (Current: ${current})
    IF    '${target_temp}' > '${current}'
        Click Button    id:climate-temp-up
    ELSE IF    '${target_temp}' < '${current}'
        Click Button    id:climate-temp-down
    END
    Capture Page Screenshot

Toggle Media Playback
    Click Button    id:media-play-pause-button
    ${state}=    Get Element Attribute    id:media-play-pause-button    data-state
    Capture Page Screenshot
    RETURN    ${state}

Verify Status Bar Information
    Element Should Be Visible    id:status-time
    Element Should Be Visible    id:status-outdoor-temp
    Element Should Be Visible    id:status-fuel
