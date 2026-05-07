*** Settings ***
# ─────────────────────────────────────────────────────────────────────────────
# common.resource — single foundation for every suite in learning-lab.
#
# Libraries loaded here:
#   SeleniumLibrary  — browser automation
#   StepCapture      — after each browser action: saves a PNG + pauses
#   VideoCapture     — records each test as an MP4 (browser tests only)
#   LearningTools    — domain utilities (parse_number, normalize_label, …)
#
# Pacing note:
#   StepCapture uses a plain time.sleep() between actions, NOT Set Selenium Speed.
#   Reason: Set Selenium Speed monkey-patches WebDriver.execute(), which would
#   also throttle VideoCapture's screenshot calls inside the background thread.
#   The time.sleep approach pauses only the main thread, leaving the capture
#   thread free to collect frames at full rate.
# ─────────────────────────────────────────────────────────────────────────────
Library    SeleniumLibrary    timeout=10    run_on_failure=Capture Page Screenshot
Library    ${CURDIR}/../libraries/StepCapture.py
...        pause_seconds=${STEP_PAUSE}    video_fps=${VIDEO_FPS}
...        ffmpeg_path=${FFMPEG_PATH}
Library    ${CURDIR}/../libraries/LearningTools.py
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem

*** Variables ***
# Override any variable from the command line, e.g.:
#   robot -v STEP_PAUSE:2.0 -v VIDEO_FPS:15 -d results tests/
#
# Pause (seconds) inserted by StepCapture after every browser-modifying keyword.
# This keeps the test watchable live and fills VideoCapture frames between actions.
# Set to 0 for CI / full-speed runs.
${STEP_PAUSE}         1.0
# Video frame rate.  At 10 fps and 1.0s pause, each action produces ~10 frames.
${VIDEO_FPS}          10
# Full path to the ffmpeg executable (override with -v FFMPEG_PATH:/other/path).
${FFMPEG_PATH}        C:/ffmpeg/bin/ffmpeg.exe
# Set TUTORIAL_HEADLESS=true in the OS environment to suppress the browser window.
${HEADLESS}           %{TUTORIAL_HEADLESS=false}
# Browser and URL — overridable without touching any test file.
${SIMULATOR_URL}      file:///${EXECDIR}/simulator/index.html
${BROWSER}            chrome

*** Keywords ***
Open Simulator
    [Documentation]    Opens the browser (with optional headless mode) and waits
    ...                for the home screen. No Set Selenium Speed — pacing is
    ...                handled by StepCapture's pause_seconds parameter.
    [Arguments]    ${url}=${SIMULATOR_URL}    ${browser}=${BROWSER}
    IF    '${HEADLESS}'.lower() in ['true', '1', 'yes']
        ${options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    modules=sys,selenium.webdriver
        Call Method    ${options}    add_argument    --headless=new
        Call Method    ${options}    add_argument    --window-size=1440,900
        Create Webdriver    Chrome    options=${options}
        Go To    ${url}
    ELSE
        Open Browser    ${url}    ${browser}
        Maximize Browser Window
    END
    Wait Until Element Is Visible    id:screen-home    timeout=8s

Go To Home Screen
    [Documentation]    Clicks the Home button and waits for the home screen.
    Click Button    id:nav-home-button
    Wait Until Element Is Visible    id:screen-home    timeout=3s

Current Screen Should Be
    [Documentation]    Asserts the bottom-bar screen indicator text (uppercase).
    [Arguments]    ${expected_name}
    Element Text Should Be    id:nav-current-screen    ${expected_name.upper()}

Capture Screenshot On Failure
    [Documentation]    Saves a page screenshot only when the calling test failed.
    Run Keyword If Test Failed    Capture Page Screenshot

Status Bar Should Be Complete
    [Documentation]    Verifies all five status-bar elements are visible.
    Element Should Be Visible    id:status-time
    Element Should Be Visible    id:status-outdoor-temp
    Element Should Be Visible    id:status-wifi
    Element Should Be Visible    id:status-bluetooth
    Element Should Be Visible    id:status-fuel

Home Screen App Icons Should Be Visible
    [Documentation]    Verifies all eight home-screen app icons are present.
    FOR    ${app}    IN    navigation    media    climate    phone    vehicle    settings    camera    weather
        Element Should Be Visible    id:app-icon-${app}
    END

Element Data State Should Change After Click
    [Documentation]    Clicks locator and asserts that data-state changed.
    ...                Returns a tuple (before, after).
    [Arguments]    ${locator}
    ${before}=    Get Element Attribute    ${locator}    data-state
    Click Button    ${locator}
    ${after}=     Get Element Attribute    ${locator}    data-state
    Should Not Be Equal    ${before}    ${after}
    ...    msg=data-state did not change after clicking ${locator}
    RETURN    ${before}    ${after}

Element Numeric Text Should Increase After Click
    [Documentation]    Reads numeric text, clicks the button, asserts the value went up.
    ...                Returns (before_int, after_int).
    [Arguments]    ${value_locator}    ${button_locator}
    ${before_text}=    Get Text    ${value_locator}
    ${before}=    Parse Number    ${before_text}
    Click Button    ${button_locator}
    ${after_text}=    Get Text    ${value_locator}
    ${after}=    Parse Number    ${after_text}
    Should Be True    ${after} > ${before}
    ...    msg=Expected numeric value to increase but got ${before} -> ${after}
    RETURN    ${before}    ${after}

Element Attribute Value Should Be
    [Documentation]    Asserts a specific HTML attribute value on an element.
    [Arguments]    ${locator}    ${attribute}    ${expected}
    ${actual}=    Get Element Attribute    ${locator}    ${attribute}
    Should Be Equal    ${actual}    ${expected}
    ...    msg=Attribute '${attribute}' on ${locator}: expected '${expected}', got '${actual}'
