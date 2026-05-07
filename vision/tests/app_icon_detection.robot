*** Settings ***
Documentation    Verifies that YOLO11 nano detects all 8 app icons on the
...              simulator home screen and that they are correctly positioned
...              in their expected grid rows.
...
...              All tests follow this pattern:
...                1. Open the simulator in Chrome
...                2. Navigate to the target state
...                3. Capture a screenshot with SeleniumLibrary
...                4. Run YOLO inference via SimulatorVision
...                5. Assert detections

Library     SeleniumLibrary    timeout=10    run_on_failure=Capture Page Screenshot
Library     OperatingSystem
Library     ${EXECDIR}/vision/libraries/SimulatorVision.py
...         model_path=${EXECDIR}/vision/model/simulator_icons.pt
...         conf_threshold=0.30

*** Variables ***
${SIMULATOR_URL}      file:///${EXECDIR}/simulator/index.html
${BROWSER}            chrome
${SCREENSHOT_DIR}     ${EXECDIR}/vision/results
${MIN_CONF}           0.25
${HIGH_CONF}          0.40

*** Test Cases ***

# ── Model sanity ──────────────────────────────────────────────────────────────

Model File Exists And Loads Without Error
    [Documentation]    Confirms the trained model file is present and can be loaded.
    [Tags]    smoke    model
    File Should Exist    ${EXECDIR}/vision/model/simulator_icons.pt
    ...    msg=Run python vision/scripts/train.py first.
    Load Vision Model

# ── Home-screen full-grid detection ──────────────────────────────────────────

All Eight App Icons Are Detected On Home Screen
    [Documentation]    Takes a screenshot of the home screen and asserts YOLO
    ...                detects all 8 icons: navigation, media, climate, phone,
    ...                vehicle, settings, camera, weather.
    [Tags]    smoke    home    grid
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_all_icons
    All App Icons Should Be Detected    ${shot}    min_conf=${MIN_CONF}
    [Teardown]    Close Browser

Exactly Eight Icons Are Detected On Home Screen
    [Documentation]    Asserts there are exactly 8 detections, not more or fewer.
    [Tags]    home    grid
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_count
    Detection Count Should Be    ${shot}    8    min_conf=${MIN_CONF}
    [Teardown]    Close Browser

# ── Top-row icons ─────────────────────────────────────────────────────────────

Top Row Contains Navigation Media Climate Phone
    [Documentation]    Verifies the first row of the icon grid contains the
    ...                four expected icons.
    [Tags]    home    grid    top-row
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_top_row
    Icons In Top Row Should Be Detected    ${shot}    min_conf=${MIN_CONF}
    [Teardown]    Close Browser

Navigation Icon Is Detected With High Confidence
    [Tags]    home    navigation
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_navigation_conf
    App Icon Should Be Detected    ${shot}    navigation    min_conf=${HIGH_CONF}
    [Teardown]    Close Browser

Media Icon Is Detected With High Confidence
    [Tags]    home    media
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_media_conf
    App Icon Should Be Detected    ${shot}    media    min_conf=${HIGH_CONF}
    [Teardown]    Close Browser

Climate Icon Is Detected With High Confidence
    [Tags]    home    climate
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_climate_conf
    App Icon Should Be Detected    ${shot}    climate    min_conf=${HIGH_CONF}
    [Teardown]    Close Browser

Phone Icon Is Detected With High Confidence
    [Tags]    home    phone
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_phone_conf
    App Icon Should Be Detected    ${shot}    phone    min_conf=${HIGH_CONF}
    [Teardown]    Close Browser

# ── Bottom-row icons ──────────────────────────────────────────────────────────

Bottom Row Contains Vehicle Settings Camera Weather
    [Documentation]    Verifies the second row of the icon grid contains the
    ...                four expected icons.
    [Tags]    home    grid    bottom-row
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_bottom_row
    Icons In Bottom Row Should Be Detected    ${shot}    min_conf=${MIN_CONF}
    [Teardown]    Close Browser

Vehicle Icon Is Detected With High Confidence
    [Tags]    home    vehicle
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_vehicle_conf
    App Icon Should Be Detected    ${shot}    vehicle    min_conf=${HIGH_CONF}
    [Teardown]    Close Browser

Settings Icon Is Detected With High Confidence
    [Tags]    home    settings
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_settings_conf
    App Icon Should Be Detected    ${shot}    settings    min_conf=${HIGH_CONF}
    [Teardown]    Close Browser

Camera Icon Is Detected With High Confidence
    [Tags]    home    camera
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_camera_conf
    App Icon Should Be Detected    ${shot}    camera    min_conf=${HIGH_CONF}
    [Teardown]    Close Browser

Weather Icon Is Detected With High Confidence
    [Tags]    home    weather
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_weather_conf
    App Icon Should Be Detected    ${shot}    weather    min_conf=${HIGH_CONF}
    [Teardown]    Close Browser

# ── Individual icon positions ─────────────────────────────────────────────────

Navigation Icon Is In The Left Half Of The Screen
    [Documentation]    Navigation is the leftmost icon — its centre X must be
    ...                in the left half of the image (cx < 0.50).  We use the
    ...                left-half rule rather than a tighter threshold because the
    ...                exact cx depends on browser window width.
    [Tags]    position    navigation
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_nav_position
    ${box}=     Get Icon Bounding Box    ${shot}    navigation
    Should Be True    ${box}[cx] < 0.50
    ...    msg=Navigation icon cx=${box}[cx] should be in the left half (<0.50)
    [Teardown]    Close Browser

Weather Icon Is In The Right Half Of The Screen
    [Documentation]    Weather is the rightmost icon — its centre X must be
    ...                in the right half of the image (cx > 0.50).
    [Tags]    position    weather
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_weather_position
    ${box}=     Get Icon Bounding Box    ${shot}    weather
    Should Be True    ${box}[cx] > 0.50
    ...    msg=Weather icon cx=${box}[cx] should be in the right half (>0.50)
    [Teardown]    Close Browser

Top Row Icons Are Above Bottom Row Icons
    [Documentation]    Every top-row icon must have a smaller centre Y than
    ...                every bottom-row icon.
    [Tags]    position    grid
    [Setup]    Open Simulator And Go To Home
    ${shot}=    Capture Screenshot    home_row_separation

    ${nav}=     Get Icon Bounding Box    ${shot}    navigation
    ${veh}=     Get Icon Bounding Box    ${shot}    vehicle
    Should Be True    ${nav}[cy] < ${veh}[cy]
    ...    msg=Navigation (cy=${nav}[cy]) is not above Vehicle (cy=${veh}[cy])

    ${med}=     Get Icon Bounding Box    ${shot}    media
    ${cam}=     Get Icon Bounding Box    ${shot}    camera
    Should Be True    ${med}[cy] < ${cam}[cy]
    ...    msg=Media (cy=${med}[cy]) is not above Camera (cy=${cam}[cy])
    [Teardown]    Close Browser

# ── Annotated evidence screenshots ───────────────────────────────────────────

Save Annotated Home Screen Detection
    [Documentation]    Produces an annotated screenshot with bounding boxes
    ...                drawn around every detected icon — useful for visual review.
    [Tags]    evidence    annotated
    [Setup]    Open Simulator And Go To Home
    ${shot}=         Capture Screenshot    home_for_annotation
    ${annotated}=    Set Variable    ${SCREENSHOT_DIR}/home_annotated.png
    Save Annotated Screenshot    ${shot}    ${annotated}
    File Should Exist    ${annotated}
    [Teardown]    Close Browser

# ── Light-theme detection ────────────────────────────────────────────────────

All Icons Still Detected In Light Theme
    [Documentation]    Switches to light mode and verifies all icons are still
    ...                detectable (tests model robustness to colour variation).
    [Tags]    home    theme    light
    [Setup]    Open Simulator And Go To Home
    # Switch to light theme
    Click Button    id:app-icon-settings
    Wait Until Element Is Visible    id:screen-settings    timeout=3s
    Click Button    id:settings-theme-toggle
    Click Button    id:nav-home-button
    Wait Until Element Is Visible    id:screen-home    timeout=3s

    ${shot}=    Capture Screenshot    home_light_theme
    All App Icons Should Be Detected    ${shot}    min_conf=${MIN_CONF}
    [Teardown]    Close Browser

# ── Debug image with class labels and confidence scores ───────────────────────

Debug Image Shows All Detected Icons With Labels And Confidence
    [Documentation]    Captures the home screen, runs detection, and produces a
    ...                debug PNG with bounding boxes, class names, and confidence
    ...                percentages drawn on each icon.  The image is embedded
    ...                directly in log.html for instant visual review.
    [Tags]    smoke    debug    annotated
    [Setup]    Open Simulator And Go To Home
    ${shot}=      Capture Screenshot    home_for_debug
    ${debug}=     Set Variable    ${SCREENSHOT_DIR}/home_debug_annotated.png
    Detect And Show Debug Image    ${shot}    ${debug}
    File Should Exist    ${debug}
    [Teardown]    Close Browser

# ── Detection summary keyword ─────────────────────────────────────────────────

Detection Summary Reports All Eight Icons
    [Documentation]    Uses Get Detection Summary and asserts the returned dict
    ...                shows count=8 and no missing icons.
    [Tags]    smoke    summary
    [Setup]    Open Simulator And Go To Home
    ${shot}=       Capture Screenshot    home_summary
    ${summary}=    Get Detection Summary    ${shot}    min_conf=${MIN_CONF}
    Should Be Equal As Integers    ${summary}[count]    8
    ...    msg=Expected 8 icons, got ${summary}[count]. Missing: ${summary}[missing]
    Should Be Empty    ${summary}[missing]
    ...    msg=Icons not detected: ${summary}[missing]
    Log    Detection summary: ${summary}
    [Teardown]    Close Browser

*** Keywords ***
Open Simulator And Go To Home
    [Documentation]    Opens Chrome at a fixed 1920x1080 viewport so screenshots
    ...                are always within the training-data size range.
    ...                Maximizing would give unpredictable resolutions and make
    ...                the icons too small relative to the YOLO 640-pixel input.
    Create Directory    ${SCREENSHOT_DIR}
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Set Window Size    1920    1080
    Wait Until Element Is Visible    id:screen-home    timeout=8s
    ${current}=    Get Text    id:nav-current-screen
    Run Keyword If    '${current}' != 'HOME'    Click Button    id:nav-home-button
    Wait Until Element Is Visible    id:screen-home    timeout=3s

Capture Screenshot
    [Documentation]    Saves a page screenshot into the vision results directory
    ...                and returns the absolute file path.
    [Arguments]    ${name}
    ${path}=    Set Variable    ${SCREENSHOT_DIR}/${name}.png
    Capture Page Screenshot    ${path}
    RETURN    ${path}
