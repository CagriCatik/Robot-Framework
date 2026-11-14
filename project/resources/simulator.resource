*** Settings ***
Library     SeleniumLibrary
Library     Collections
Library     String
Library     DateTime
Resource    mappings.resource

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
    Set Window Size    1440    900
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Capture Page Screenshot

Go To Home
    Scroll Element Into View    id:nav-home-button
    Click Button    id:nav-home-button
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Element Text Should Be    id:nav-current-screen    HOME
    Capture Page Screenshot

Navigate To App
    [Arguments]    ${app_name}
    ${key}=    Convert To Lower Case    ${app_name}
    Dictionary Should Contain Key    ${APP_ICONS}    ${key}
    ...    msg=Unknown app '${app_name}'. Valid keys: ${APP_ICONS.keys()}
    Scroll Element Into View    ${APP_ICONS}[${key}]
    Click Button    ${APP_ICONS}[${key}]
    Wait Until Element Is Visible    ${APP_SCREENS}[${key}]    timeout=5s
    Element Text Should Be    id:nav-current-screen    ${APP_TITLES}[${key}]
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

Verify Obstacle Simulation Level
    [Arguments]    ${level}
    Dictionary Should Contain Key    ${OBSTACLE_DISTANCES}    ${level}
    Click Button    id:camera-sim-obstacle-${level}
    Element Attribute Value Should Be    id:sensor-rear-left    data-state    ${level}
    Element Text Should Be               id:sensor-rear-distance    ${OBSTACLE_DISTANCES}[${level}]

Verify Language Greeting Mapping
    [Arguments]    ${lang_code}
    Dictionary Should Contain Key    ${LANGUAGE_GREETINGS}    ${lang_code}
    Navigate To App    settings
    Select From List By Value    id:settings-language-select    ${lang_code}
    Go To Home
    Element Text Should Be    css:#screen-home .home-welcome    ${LANGUAGE_GREETINGS}[${lang_code}]
