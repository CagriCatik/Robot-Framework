# Tutorial 11 — Resource Files

## The Scenario

Three test files all contain `Open Climate Screen`. When the simulator redesign moves the Climate button from `id:app-icon-climate` to `id:nav-climate`, you update three files. Next month, the media locators change and you update four more. A month after that someone added a fifth file nobody told you about and the locator is still wrong.

Resource files end this. One file owns the locators and keywords for one screen. Every suite that needs them imports that file. One change propagates everywhere.

## The Structure You Are Building

```text
resources/
├── common.resource          ← browser setup, simulator URL, shared lifecycle
├── climate_page.resource    ← climate screen locators + keywords
├── media_page.resource      ← media screen locators + keywords
├── settings_page.resource   ← settings screen locators + keywords
└── navigation_page.resource ← navigation screen locators + keywords
```

Each file owns exactly one area of responsibility. Test suites import only what they need.

## Step 1 — `common.resource`

This file is the foundation imported by every other resource and test suite.

Create `resources/common.resource`:

```robot
*** Settings ***
Library    SeleniumLibrary    timeout=10    run_on_failure=Capture Page Screenshot
Library    Collections
Library    String

*** Variables ***
${SIMULATOR_URL}    file:///${EXECDIR}/simulator/index.html
${BROWSER}          chrome

*** Keywords ***
Open Simulator
    [Arguments]    ${url}=${SIMULATOR_URL}    ${browser}=${BROWSER}
    Open Browser    ${url}    ${browser}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=8s

Go To Home Screen
    Click Button    id:nav-home-button
    Wait Until Element Is Visible    id:screen-home    timeout=3s

Capture Screenshot On Failure
    Run Keyword If Test Failed    Capture Page Screenshot
```

## Step 2 — `climate_page.resource`

All climate locators live here. No test suite ever references `id:climate-temp-up` directly.

Create `resources/climate_page.resource`:

```robot
*** Settings ***
Resource    ${CURDIR}/common.resource

*** Variables ***
${CLIMATE_SCREEN}          id:screen-climate
${DRIVER_TEMP_DISPLAY}     id:climate-temperature-value
${PASSENGER_TEMP_DISPLAY}  id:climate-passenger-temp-value
${TEMP_UP_BTN}             id:climate-temp-up
${TEMP_DOWN_BTN}           id:climate-temp-down
${FAN_SPEED_DISPLAY}       id:climate-fan-speed-value
${FAN_UP_BTN}              id:climate-fan-up
${FAN_DOWN_BTN}            id:climate-fan-down
${DRIVER_SEAT_HEAT_BTN}    id:climate-driver-seat-heat
${AC_TOGGLE}               id:climate-ac-toggle
${SYNC_TOGGLE}             id:climate-sync-toggle
${DEFROST_TOGGLE}          id:climate-defrost-toggle

*** Keywords ***
Open Climate Screen
    [Documentation]    Opens the browser (if not already open) and navigates to the climate screen.
    Open Simulator
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    ${CLIMATE_SCREEN}    timeout=3s

Get Driver Temperature
    [Documentation]    Returns the driver temperature string, e.g. "22°C".
    ${value}=    Get Text    ${DRIVER_TEMP_DISPLAY}
    RETURN    ${value}

Set Driver Temperature To
    [Arguments]    ${target_celsius}
    [Documentation]    Clicks up or down until the driver temperature reaches the target.
    ...                target_celsius must be an integer between 16 and 30.
    ${current_str}=    Get Text    ${DRIVER_TEMP_DISPLAY}
    ${current}=    Evaluate    int("${current_str}".replace("°C",""))
    ${diff}=    Evaluate    ${target_celsius} - ${current}
    IF    ${diff} > 0
        FOR    ${i}    IN RANGE    ${diff}
            Click Button    ${TEMP_UP_BTN}
        END
    ELSE IF    ${diff} < 0
        FOR    ${i}    IN RANGE    ${diff.__abs__()}
            Click Button    ${TEMP_DOWN_BTN}
        END
    END

Driver Temperature Should Be
    [Arguments]    ${expected}
    [Documentation]    Asserts the driver temperature display equals expected value (e.g. "24°C").
    ${actual}=    Get Driver Temperature
    Should Be Equal    ${actual}    ${expected}
    ...    msg=Driver temperature: expected ${expected}, got ${actual}

Toggle AC
    Click Button    ${AC_TOGGLE}

AC State Should Be
    [Arguments]    ${expected_state}
    [Documentation]    Asserts data-state attribute is "on" or "off".
    ${actual}=    Get Element Attribute    ${AC_TOGGLE}    data-state
    Should Be Equal    ${actual}    ${expected_state}

Cycle Driver Seat Heat
    [Documentation]    Clicks seat heat once. Returns the new state (off/low/high).
    Click Button    ${DRIVER_SEAT_HEAT_BTN}
    ${state}=    Get Element Attribute    ${DRIVER_SEAT_HEAT_BTN}    data-state
    RETURN    ${state}
```

## Step 3 — `media_page.resource`

Create `resources/media_page.resource`:

```robot
*** Settings ***
Resource    ${CURDIR}/common.resource

*** Variables ***
${MEDIA_SCREEN}        id:screen-media
${TRACK_NAME}          id:media-track-name
${ARTIST_NAME}         id:media-artist-name
${PLAY_PAUSE_BTN}      id:media-play-pause-button
${NEXT_BTN}            id:media-next-button
${PREV_BTN}            id:media-prev-button
${VOLUME_VALUE}        id:media-volume-value
${VOLUME_UP_BTN}       id:media-volume-up
${VOLUME_DOWN_BTN}     id:media-volume-down
${SOURCE_RADIO_TAB}    id:media-source-radio
${SOURCE_BT_TAB}       id:media-source-bluetooth
${SOURCE_USB_TAB}      id:media-source-usb

*** Keywords ***
Open Media Screen
    Open Simulator
    Click Button    id:app-icon-media
    Wait Until Element Is Visible    ${MEDIA_SCREEN}    timeout=3s

Get Current Track Name
    ${name}=    Get Text    ${TRACK_NAME}
    RETURN    ${name}

Get Volume Level
    [Documentation]    Returns the volume as an integer.
    ${raw}=    Get Text    ${VOLUME_VALUE}
    ${vol}=    Convert To Integer    ${raw}
    RETURN    ${vol}

Set Volume To
    [Arguments]    ${target}
    [Documentation]    Clicks volume up or down until the displayed value matches target.
    ${current}=    Get Volume Level
    ${diff}=    Evaluate    ${target} - ${current}
    IF    ${diff} > 0
        FOR    ${i}    IN RANGE    ${diff // 5}
            Click Button    ${VOLUME_UP_BTN}
        END
    ELSE IF    ${diff} < 0
        FOR    ${i}    IN RANGE    (${diff}.__abs__() // 5)
            Click Button    ${VOLUME_DOWN_BTN}
        END
    END

Toggle Playback
    [Documentation]    Clicks play/pause and returns the new data-state.
    Click Button    ${PLAY_PAUSE_BTN}
    ${state}=    Get Element Attribute    ${PLAY_PAUSE_BTN}    data-state
    RETURN    ${state}

Switch Media Source To
    [Arguments]    ${source}
    [Documentation]    Clicks the source tab. source must be radio, bluetooth, or usb.
    Click Button    id:media-source-${source}
    Wait Until Element Contains    id:media-source-${source}    active
```

## Step 4 — Use the Resources in a Test Suite

Create `tests/climate_tests.robot`:

```robot
*** Settings ***
Resource         ${CURDIR}/../resources/climate_page.resource
Suite Setup      Open Climate Screen
Suite Teardown   Close All Browsers
Test Teardown    Run Keywords
...    Go To Home Screen
...    AND    Capture Screenshot On Failure
Test Tags    climate

*** Test Cases ***
Default Driver Temperature Is 22
    [Tags]    smoke
    Driver Temperature Should Be    22°C

Temperature Can Be Set To 26
    Set Driver Temperature To    26
    Driver Temperature Should Be    26°C

Temperature Ceiling Is 30
    Set Driver Temperature To    30
    Driver Temperature Should Be    30°C
    # One more click should not change the value
    Click Button    ${TEMP_UP_BTN}
    Driver Temperature Should Be    30°C

AC Starts Enabled And Can Be Toggled
    AC State Should Be    on
    Toggle AC
    AC State Should Be    off
    Toggle AC
    AC State Should Be    on

Seat Heat Cycles Off Low High
    ${state}=    Cycle Driver Seat Heat
    Should Be Equal    ${state}    low
    ${state}=    Cycle Driver Seat Heat
    Should Be Equal    ${state}    high
    ${state}=    Cycle Driver Seat Heat
    Should Be Equal    ${state}    off
```

Create `tests/media_tests.robot`:

```robot
*** Settings ***
Resource         ${CURDIR}/../resources/media_page.resource
Suite Setup      Open Media Screen
Suite Teardown   Close All Browsers
Test Teardown    Capture Screenshot On Failure
Test Tags    media

*** Test Cases ***
Track Name Is Not Empty On Load
    [Tags]    smoke
    ${name}=    Get Current Track Name
    Should Not Be Empty    ${name}

Play Pause Toggles Correctly
    [Tags]    smoke
    ${state1}=    Toggle Playback
    Should Be Equal    ${state1}    paused
    ${state2}=    Toggle Playback
    Should Be Equal    ${state2}    playing

Next Track Changes Track Name
    ${before}=    Get Current Track Name
    Click Button    ${NEXT_BTN}
    ${after}=     Get Current Track Name
    Should Not Be Equal    ${before}    ${after}

Volume Goes Up By 5 Each Click
    ${before}=    Get Volume Level
    Click Button    ${VOLUME_UP_BTN}
    ${after}=     Get Volume Level
    ${diff}=    Evaluate    ${after} - ${before}
    Should Be Equal As Integers    ${diff}    5
```

Run both suites:

```powershell
robot -d results tests/climate_tests.robot tests/media_tests.robot
```

## Why the Locators Are in the Resource, Not the Test

When the simulator redesign renames `id:climate-temp-up` to `id:climate-driver-temp-up`, you change one line in `climate_page.resource`. All fourteen tests that use `Set Driver Temperature To` or click `${TEMP_UP_BTN}` are fixed without touching a single test file.

This is the core benefit of the resource file pattern. It is not about DRY (Don't Repeat Yourself) as an abstract principle — it is about making locator changes survivable in a growing test suite.

## Practice Challenge

Create `resources/vehicle_page.resource` with:

- Variables for `id:vehicle-fuel-value`, `id:vehicle-tire-fl`, `id:vehicle-tire-fl-value` (and the other three tires)
- A keyword `Open Vehicle Screen`
- A keyword `Fuel Level Should Be    ${expected_percent}` that reads and asserts the fuel value
- A keyword `All Tire Pressures Should Be OK` that reads all four tire `data-state` attributes and asserts each is `"ok"`

Write a test suite `tests/vehicle_tests.robot` that uses the resource and passes.
