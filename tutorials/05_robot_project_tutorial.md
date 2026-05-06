# Tutorial 05 — Project Structure and File Anatomy

## The Scenario

Your simulator tests are growing. You have climate tests, media tests, and navigation tests — all crammed into one file. That file is already 200 lines and nobody can find anything. This tutorial shows you how a Robot Framework project is actually organized, section by section, so you can split the work cleanly.

## The Four Sections — What Each One Is For

Every `.robot` or `.resource` file is made of up to four sections. Each section starts with `*** Section Name ***` at the beginning of the line.

```robot
*** Settings ***      ← imports, metadata, lifecycle hooks
*** Variables ***     ← file-scope constants and defaults
*** Test Cases ***    ← the actual tests (only in .robot files)
*** Keywords ***      ← reusable building blocks
```

`.resource` files look identical but **cannot** contain `*** Test Cases ***`. That distinction is enforced by the parser — if you accidentally add test cases to a resource file, Robot Framework refuses to import it.

## A Fully Annotated Suite File

Study this file before creating it. Every line has a purpose.

Create `tests/05_anatomy.robot`:

```robot
*** Settings ***
# What this suite needs to run
Library     SeleniumLibrary

# Shared keywords and variables from the project
Resource    ${CURDIR}/../resources/common.resource

# One description shown in report.html under this suite
Documentation    Demonstrates all four Robot Framework file sections.
...              Tests run against the local simulator.

# Metadata appears in report.html — useful for versioning and ownership
Metadata    Feature     Climate Control
Metadata    Owner       QA Team

# Suite-level hooks: run once before/after ALL tests in this file
Suite Setup     Open Simulator Browser
Suite Teardown  Close All Browsers

# Test-level hooks: run before/after EACH test
Test Setup      Navigate To Home Screen
Test Teardown   Capture Screenshot On Failure

# Every test in this file gets these tags automatically
Test Tags    anatomy    climate

*** Variables ***
# Constants used in multiple tests — no hardcoding inside test cases
${DEFAULT_DRIVER_TEMP}    22
${DEFAULT_FAN_SPEED}      2
${MIN_TEMP}               16
${MAX_TEMP}               30

*** Test Cases ***
Climate Screen Opens From Home
    [Documentation]    Clicking the Climate icon must show the climate screen.
    [Tags]    smoke
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    Element Text Should Be    id:nav-current-screen    CLIMATE

Default Driver Temperature Is 22 Degrees
    [Documentation]    On first load, driver temperature must be 22°C.
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    Element Text Should Be    id:climate-temperature-value    ${DEFAULT_DRIVER_TEMP}°C

Temperature Up Button Increases The Value
    [Documentation]    Each click on the up button adds 1°C.
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    ${before}=    Get Text    id:climate-temperature-value
    Click Button   id:climate-temp-up
    ${after}=     Get Text    id:climate-temperature-value
    Should Not Be Equal    ${before}    ${after}

*** Keywords ***
# Keywords defined HERE are local to this file.
# If the same keyword is needed in other suites, it belongs in a resource file.

Open Simulator Browser
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=8s

Navigate To Home Screen
    Click Button    id:nav-home-button
    Wait Until Element Is Visible    id:screen-home    timeout=3s

Capture Screenshot On Failure
    Run Keyword If Test Failed    Capture Page Screenshot
```

And create `resources/common.resource` (if it does not exist yet):

```robot
*** Variables ***
${SIMULATOR_URL}    file:///${EXECDIR}/simulator/index.html
${BROWSER}          chrome
```

Run:

```powershell
robot -d results tests/05_anatomy.robot
```

Open `report.html`. Notice the metadata block (`Feature: Climate Control`, `Owner: QA Team`) and the tags (`anatomy`, `climate`, `smoke`) on the summary page.

## The 2-Space Separator Rule

Robot Framework uses **two or more spaces** to tell tokens apart on one line. One space is treated as part of the token value — not a separator. This is the single most common syntax error for beginners.

```robot
# WRONG — "Log Hello World" is one unknown keyword name
    Log Hello World

# CORRECT — "Log" is the keyword, "Hello World" is the argument
    Log    Hello World

# WRONG — "Should Be Equal one two" is one unknown keyword name
    Should Be Equal one two

# CORRECT — three separate tokens
    Should Be Equal    one    two
```

## Continuation Lines

Long settings or keyword calls can span multiple lines using `...`:

```robot
*** Settings ***
Documentation    This suite covers all climate control interactions
...              for the automotive center display simulator.
...              See resources/climate_page.resource for locator details.

Suite Setup    Run Keywords
...    Open Simulator Browser
...    AND    Navigate To Home Screen
```

The `...` must be at the same indentation level as the line it continues. Mixing indentation breaks the parser.

## The `__init__.robot` File

When a folder is treated as a suite (because it contains `.robot` files), you can add `__init__.robot` to that folder. It sets suite-level settings for the entire folder — documentation, tags, and setup/teardown that wrap every child suite.

Create `tests/__init__.robot`:

```robot
*** Settings ***
Documentation    Top-level suite for all simulator automation tests.
Suite Setup      Log    Starting full simulator test run
Suite Teardown   Log    Simulator test run complete
```

Now run the whole folder:

```powershell
robot -d results tests/
```

In `log.html`, you will see the folder-level setup and teardown wrapped around all the individual suites. This is how large projects ensure shared startup/cleanup without duplicating it in every file.

## What `.resource` vs `.robot` Means in Practice

| Question | `.robot` | `.resource` |
| --- | --- | --- |
| Can it be executed with `robot`? | Yes | No |
| Can it contain test cases? | Yes | No |
| Can it contain keywords? | Yes | Yes |
| Can it contain variables? | Yes | Yes |
| Typical use | Test suites | Shared keywords, locators, page objects |

If a file accidentally contains `*** Test Cases ***` in a `.resource` file, the import fails immediately with:

```text
Error in file '.../some_file.resource':
Resource file cannot contain tests or tasks.
```

## Practice Challenge

Create `tests/05_media_anatomy.robot` with:

- `Suite Setup` that opens the browser and navigates to the media screen
- `Suite Teardown` that closes all browsers
- `Test Teardown` that captures a screenshot on failure
- One test that reads `id:media-track-name` and asserts it is not empty
- One test that clicks `id:media-play-pause-button` and checks that `data-state` changes

Run dry run first: `robot --dryrun tests/05_media_anatomy.robot`
Then run normally and verify both tests pass.
