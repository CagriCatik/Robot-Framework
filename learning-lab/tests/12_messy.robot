*** Settings ***
Documentation    Tutorial 12 — BEFORE refactoring. Read this file as a negative example.
...              Problems: Sleep instead of Wait, no assertions, hardcoded URLs and locators,
...              vague test names, no tags, browser opened three times unnecessarily.
Library    SeleniumLibrary

*** Test Cases ***
test1
    Open Browser    file:///${EXECDIR}/simulator/index.html    chrome
    Maximize Browser Window
    Sleep    2s
    Click Button    id:app-icon-climate
    Sleep    1s
    Get Text    id:climate-temperature-value
    Click Button    id:climate-temp-up
    Click Button    id:climate-temp-up
    Click Button    id:climate-temp-up
    Get Text    id:climate-temperature-value
    Close Browser

test2
    Open Browser    file:///${EXECDIR}/simulator/index.html    chrome
    Maximize Browser Window
    Sleep    2s
    Click Button    id:app-icon-settings
    Sleep    1s
    Click Button    id:settings-theme-toggle
    Get Element Attribute    id:settings-theme-toggle    data-state
    Click Button    id:settings-wifi-toggle
    Get Element Attribute    id:settings-wifi-toggle    data-state
    Click Button    id:settings-brightness-up
    Get Text    id:settings-brightness-value
    Close Browser

test3
    Open Browser    file:///${EXECDIR}/simulator/index.html    chrome
    Maximize Browser Window
    Sleep    2s
    Click Button    id:app-icon-media
    Sleep    1s
    Click Button    id:media-play-pause-button
    Get Element Attribute    id:media-play-pause-button    data-state
    Click Button    id:media-next-button
    Get Text    id:media-track-name
    Close Browser
