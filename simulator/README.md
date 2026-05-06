# Center Information Display Simulator

A browser-based automotive infotainment center display simulator built with plain HTML, CSS, and JavaScript. Designed as a mockup target for Robot Framework automation tests.

## How to Run

Open `index.html` directly in any modern browser — no server, build step, or installation required.

```bash
# From the simulator/ folder, double-click index.html
# or open it via the file path:
start simulator/index.html          # Windows
open  simulator/index.html          # macOS
xdg-open simulator/index.html       # Linux
```

For SeleniumLibrary tests, point the browser at the absolute file path:

```text
file:///C:/Users/mccat/Desktop/Robot-Framework/simulator/index.html
```

## Apps / Screens

| Screen | How to open |
| ------ | ----------- |
| Home | Click **⌂ Home** in the bottom nav or `app-icon-*` buttons |
| Navigation | `app-icon-navigation` |
| Media | `app-icon-media` |
| Climate Control | `app-icon-climate` |
| Phone | `app-icon-phone` |
| Vehicle Status | `app-icon-vehicle` |
| Settings | `app-icon-settings` |
| Camera | `app-icon-camera` |

## Key Test IDs

All interactive elements carry stable `id` and `data-testid` attributes.

### Navigation

| ID | Element |
| -- | ------- |
| `nav-home-button` | Go to Home screen |
| `nav-back-button` | Go back |
| `nav-volume-up` / `nav-volume-down` | Global volume |
| `nav-volume-value` | Current volume (text) |
| `nav-mute-button` | Toggle mute |
| `nav-current-screen` | Active screen name indicator |

### Status Bar

| ID | Element |
| -- | ------- |
| `status-time` | Current time (updates every second) |
| `status-outdoor-temp` | Outdoor temperature |
| `status-wifi` | Wi-Fi status (`data-state`: on/off) |
| `status-bluetooth` | Bluetooth status (`data-state`: on/off) |
| `status-fuel` | Fuel level |
| `status-app-title` | Currently displayed app name |

### Home Screen

| ID | Element |
| -- | ------- |
| `screen-home` | Home screen container |
| `app-icon-navigation` | Navigation app icon |
| `app-icon-media` | Media app icon |
| `app-icon-climate` | Climate app icon |
| `app-icon-phone` | Phone app icon |
| `app-icon-vehicle` | Vehicle Status icon |
| `app-icon-settings` | Settings icon |
| `app-icon-camera` | Camera icon |
| `app-icon-weather` | Weather icon |
| `home-date` | Current date string |
| `home-np-track` | Now-playing track name |
| `home-np-artist` | Now-playing artist |

### Climate Screen

| ID | Element |
| -- | ------- |
| `screen-climate` | Climate screen container |
| `climate-temp-up` | Increase driver temperature |
| `climate-temp-down` | Decrease driver temperature |
| `climate-temperature-value` | Driver temperature display |
| `climate-passenger-temp-up` / `climate-passenger-temp-down` | Passenger temp controls |
| `climate-passenger-temp-value` | Passenger temperature display |
| `climate-fan-up` / `climate-fan-down` | Fan speed controls |
| `climate-fan-speed-value` | Fan speed display |
| `climate-driver-seat-heat` | Driver seat heat (`data-state`: off/low/high) |
| `climate-passenger-seat-heat` | Passenger seat heat |
| `climate-ac-toggle` | A/C toggle (`data-state`: on/off) |
| `climate-sync-toggle` | Sync temperatures |
| `climate-defrost-toggle` | Defrost toggle |
| `climate-recirculate-toggle` | Recirculation toggle |

### Media Screen

| ID | Element |
| -- | ------- |
| `screen-media` | Media screen container |
| `media-source-radio` / `media-source-bluetooth` / `media-source-usb` | Source tabs |
| `media-track-name` | Track/station name |
| `media-artist-name` | Artist name |
| `media-source-display` | Source detail |
| `media-play-pause-button` | Play/Pause (`data-state`: playing/paused) |
| `media-next-button` / `media-prev-button` | Track navigation |
| `media-volume-value` | Volume number |
| `media-volume-fill` | Volume bar fill |
| `media-volume-up` / `media-volume-down` | Volume buttons |
| `media-elapsed-time` / `media-total-time` | Track duration |

### Phone Screen

| ID | Element |
| -- | ------- |
| `screen-phone` | Phone screen container |
| `phone-bluetooth-toggle` | Bluetooth toggle (`data-state`: on/off) |
| `phone-call-status` | Active call overlay (hidden when not in call) |
| `phone-call-contact` | Name + number of active call |
| `phone-call-duration` | Call timer (mm:ss) |
| `phone-end-call` | End call button |
| `contact-alice` / `contact-bob` / `contact-carol` / `contact-dave` | Contact rows |
| `phone-dial-display` | Dialed number buffer |
| `dial-key-0` … `dial-key-9`, `dial-key-star`, `dial-key-hash` | Dialpad buttons |
| `phone-call-button` | Call dialed number |
| `phone-dial-clear` | Delete last digit |

### Vehicle Status Screen

| ID | Element |
| -- | ------- |
| `screen-vehicle` | Vehicle screen container |
| `vehicle-fuel-value` | Fuel percentage |
| `vehicle-fuel-gauge` | Fuel gauge bar |
| `vehicle-battery-value` | Battery voltage |
| `vehicle-oil-value` | Oil temperature |
| `vehicle-odometer-value` | Odometer reading |
| `vehicle-speed-value` | Current speed |
| `vehicle-trip-value` | Trip distance |
| `vehicle-tire-fl-value` … `vehicle-tire-rr-value` | Tire pressures |
| `vehicle-tire-fl` … `vehicle-tire-rr` | Tire indicators (`data-state`: ok/warning/danger) |

### Settings Screen

| ID | Element |
| -- | ------- |
| `screen-settings` | Settings screen container |
| `settings-theme-toggle` | Dark/Light toggle (`data-state`: dark/light) |
| `settings-brightness-up` / `settings-brightness-down` | Brightness controls |
| `settings-brightness-value` | Brightness percentage |
| `settings-language-select` | Language dropdown |
| `settings-units-toggle` | Metric/Imperial toggle (`data-state`: metric/imperial) |
| `settings-bluetooth-toggle` | Bluetooth (`data-state`: on/off) |
| `settings-wifi-toggle` | Wi-Fi (`data-state`: on/off) |
| `settings-version-value` | System version string |

### Camera Screen

| ID | Element |
| -- | ------- |
| `screen-camera` | Camera screen container |
| `camera-view-rear` / `camera-view-front` / `camera-view-360` | View selector tabs |
| `camera-feed` | Camera feed area (`data-view`: rear/front/360) |
| `camera-view-label` | View label text overlay |
| `sensor-rear-distance` / `sensor-front-distance` | Distance text |
| `sensor-rear-left` … `sensor-front-right` | Sensor dots (`data-state`: clear/medium/near) |
| `camera-sim-obstacle-near` / `camera-sim-obstacle-medium` / `camera-sim-obstacle-clear` | Test controls |

---

## Robot Framework Test Example

```robot
*** Settings ***
Library     SeleniumLibrary
Suite Setup     Open Simulator
Suite Teardown  Close All Browsers

*** Variables ***
${SIMULATOR_URL}    file:///C:/Users/mccat/Desktop/Robot-Framework/simulator/index.html
${BROWSER}          chrome

*** Test Cases ***

Home Screen Displays All App Icons
    [Tags]    smoke    home
    Element Should Be Visible    id:screen-home
    Element Should Be Visible    id:app-icon-navigation
    Element Should Be Visible    id:app-icon-media
    Element Should Be Visible    id:app-icon-climate
    Element Should Be Visible    id:app-icon-phone
    Element Should Be Visible    id:app-icon-vehicle
    Element Should Be Visible    id:app-icon-settings
    Element Should Be Visible    id:app-icon-camera

Navigate To Climate And Back
    [Tags]    smoke    navigation
    Click Button    id:app-icon-climate
    Element Should Be Visible    id:screen-climate
    Element Text Should Be       id:nav-current-screen    CLIMATE
    Click Button    id:nav-home-button
    Element Should Be Visible    id:screen-home
    Element Text Should Be       id:nav-current-screen    HOME

Climate Temperature Can Be Increased
    [Tags]    climate    functional
    Click Button    id:app-icon-climate
    ${before}=    Get Text    id:climate-temperature-value
    Click Button    id:climate-temp-up
    ${after}=     Get Text    id:climate-temperature-value
    Should Not Be Equal    ${before}    ${after}
    [Teardown]    Click Button    id:nav-home-button

Climate Temperature Bounded At Maximum
    [Tags]    climate    boundary
    Click Button    id:app-icon-climate
    FOR    ${i}    IN RANGE    20
        Click Button    id:climate-temp-up
    END
    ${value}=    Get Text    id:climate-temperature-value
    Should Be Equal    ${value}    30°C
    [Teardown]    Click Button    id:nav-home-button

Fan Speed Can Be Adjusted
    [Tags]    climate    functional
    Click Button    id:app-icon-climate
    ${before}=    Get Text    id:climate-fan-speed-value
    Click Button    id:climate-fan-up
    ${after}=     Get Text    id:climate-fan-speed-value
    Should Not Be Equal    ${before}    ${after}
    [Teardown]    Click Button    id:nav-home-button

AC Toggle Changes State
    [Tags]    climate    toggle
    Click Button    id:app-icon-climate
    ${state_before}=    Get Element Attribute    id:climate-ac-toggle    data-state
    Click Button    id:climate-ac-toggle
    ${state_after}=     Get Element Attribute    id:climate-ac-toggle    data-state
    Should Not Be Equal    ${state_before}    ${state_after}
    [Teardown]    Click Button    id:nav-home-button

Seat Heat Cycles Through States
    [Tags]    climate    toggle
    Click Button    id:app-icon-climate
    ${el}=    Get Element Attribute    id:climate-driver-seat-heat    data-state
    Should Be Equal    ${el}    off
    Click Button    id:climate-driver-seat-heat
    ${el}=    Get Element Attribute    id:climate-driver-seat-heat    data-state
    Should Be Equal    ${el}    low
    Click Button    id:climate-driver-seat-heat
    ${el}=    Get Element Attribute    id:climate-driver-seat-heat    data-state
    Should Be Equal    ${el}    high
    Click Button    id:climate-driver-seat-heat
    ${el}=    Get Element Attribute    id:climate-driver-seat-heat    data-state
    Should Be Equal    ${el}    off
    [Teardown]    Click Button    id:nav-home-button

Media Play Pause Button Toggles State
    [Tags]    media    toggle
    Click Button    id:app-icon-media
    ${state}=    Get Element Attribute    id:media-play-pause-button    data-state
    Should Be Equal    ${state}    playing
    Click Button    id:media-play-pause-button
    ${state}=    Get Element Attribute    id:media-play-pause-button    data-state
    Should Be Equal    ${state}    paused
    [Teardown]    Click Button    id:nav-home-button

Volume Up Increases Volume Value
    [Tags]    media    functional
    Click Button    id:app-icon-media
    ${before}=    Get Text    id:media-volume-value
    Click Button    id:media-volume-up
    ${after}=     Get Text    id:media-volume-value
    ${before_int}=    Convert To Integer    ${before}
    ${after_int}=     Convert To Integer    ${after}
    Should Be True    ${after_int} > ${before_int}
    [Teardown]    Click Button    id:nav-home-button

Settings Theme Toggle Switches Theme
    [Tags]    settings    toggle
    Click Button    id:app-icon-settings
    ${before}=    Get Element Attribute    id:settings-theme-toggle    data-state
    Click Button    id:settings-theme-toggle
    ${after}=     Get Element Attribute    id:settings-theme-toggle    data-state
    Should Not Be Equal    ${before}    ${after}
    [Teardown]    Click Button    id:nav-home-button

Camera View Changes On Tab Click
    [Tags]    camera    functional
    Click Button    id:app-icon-camera
    Element Text Should Be    id:camera-view-label    REAR VIEW
    Click Button    id:camera-view-front
    Element Text Should Be    id:camera-view-label    FRONT VIEW
    ${feed_view}=    Get Element Attribute    id:camera-feed    data-view
    Should Be Equal    ${feed_view}    front
    [Teardown]    Click Button    id:nav-home-button

Camera Obstacle Simulation Updates Sensor State
    [Tags]    camera    functional
    Click Button    id:app-icon-camera
    # verify clear by default
    ${state}=    Get Element Attribute    id:sensor-rear-left    data-state
    Should Be Equal    ${state}    clear
    # simulate near obstacle
    Click Button    id:camera-sim-obstacle-near
    ${state}=    Get Element Attribute    id:sensor-rear-left    data-state
    Should Be Equal    ${state}    near
    Element Text Should Be    id:sensor-rear-distance    < 0.3 m
    # clear it
    Click Button    id:camera-sim-obstacle-clear
    ${state}=    Get Element Attribute    id:sensor-rear-left    data-state
    Should Be Equal    ${state}    clear
    [Teardown]    Click Button    id:nav-home-button

Status Bar Clock Is Visible And Not Empty
    [Tags]    smoke    status-bar
    ${time}=    Get Text    id:status-time
    Should Match Regexp    ${time}    \\d{2}:\\d{2}
```

## Locators & Automation Strategy

The simulator is designed to be highly "testable." When writing Robot Framework tests, you can use several strategies to locate elements:

### 1. ID Locators (Recommended)
IDs are the most stable and performant way to find elements. Most interactive elements in this simulator have a unique `id`.
- **Robot Example**: `Click Button    id:app-icon-media`
- **HTML**: `<button id="app-icon-media">`

### 2. XPath
XPath is powerful for finding elements based on their text content or their position in the HTML tree.
- **Robot Example**: `Wait Until Element Is Visible    xpath=//button[contains(., 'Accept')]`
- **When to use**: When you need to find an element by text or when an ID is not available.

### 3. CSS Selectors
CSS selectors are concise and fast. They are great for selecting elements by class or attributes.
- **Robot Example**: `Click Element    css:.seat-heat-btn`
- **HTML**: `<button class="seat-heat-btn">`

### 4. Data Attributes
The simulator uses `data-state` attributes to track the internal state of components. You can verify these using `Get Element Attribute`.
- **Robot Example**: 
  ```robot
  ${state}=    Get Element Attribute    id:climate-ac-toggle    data-state
  Should Be Equal    ${state}    on
  ```

