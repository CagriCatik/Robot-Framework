# Tutorial 01 — Your First Real Automation Test

## The Scenario

You have just received access to the automotive center display simulator. Your job is to verify that the home screen loads correctly and that clicking an app icon actually switches screens. These are not unit tests — they are end-to-end checks run against a real browser.

By the end of this tutorial you will have a test that opens a browser, interacts with the simulator, and produces a `log.html` file you can step through.

## Prerequisites

- Python 3.8+ and pip installed
- Robot Framework and SeleniumLibrary installed:

```powershell
pip install robotframework robotframework-seleniumlibrary
```

- Chrome installed (Selenium 4.6+ manages the driver automatically)
- The simulator is at `simulator/index.html` in the project root

## What Is Robot Framework Actually Doing?

When you run `robot tests/my_test.robot`, the framework:

1. Parses the file and builds an execution plan
2. Calls library functions (like SeleniumLibrary's `Open Browser`) one by one
3. Checks assertions — any failure raises an exception and marks the test red
4. Writes `output.xml`, then generates `log.html` and `report.html` from it

The `.robot` file is not a script. It is structured data. The framework drives the execution — you describe **what** should happen, the libraries do **how**.

## Step 1 — Write Your First Test

Create `tests/01_first_test.robot` (run commands from the project root):

```robot
*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${SIMULATOR_URL}    file:///${EXECDIR}/simulator/index.html
${BROWSER}          chrome

*** Test Cases ***
Home Screen Loads With All App Icons
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=5s

    Element Should Be Visible    id:app-icon-navigation
    Element Should Be Visible    id:app-icon-media
    Element Should Be Visible    id:app-icon-climate
    Element Should Be Visible    id:app-icon-phone
    Element Should Be Visible    id:app-icon-vehicle
    Element Should Be Visible    id:app-icon-settings
    Element Should Be Visible    id:app-icon-camera
    Element Should Be Visible    id:app-icon-weather

    [Teardown]    Close Browser
```

Run it:

```powershell
robot -d results tests/01_first_test.robot
```

Open `results/log.html`. You should see eight green keyword calls, each confirming an app icon is present.

## Step 2 — Test Navigation Between Screens

The previous test only checks that icons exist. This one clicks an icon and verifies the screen actually changes.

Add a second test case to the same file:

```robot
*** Test Cases ***
Clicking Climate Icon Opens Climate Screen
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=5s

    # Confirm we start on the home screen
    Element Text Should Be    id:nav-current-screen    HOME

    # Click the Climate icon
    Click Button    id:app-icon-climate

    # The screen indicator must update
    Wait Until Element Contains    id:nav-current-screen    CLIMATE    timeout=3s

    # The climate screen must be visible
    Element Should Be Visible    id:screen-climate

    # Return home and verify
    Click Button    id:nav-home-button
    Wait Until Element Contains    id:nav-current-screen    HOME    timeout=3s

    [Teardown]    Close Browser
```

Run:

```powershell
robot -d results tests/01_first_test.robot
```

Both tests should pass. Open `log.html` and expand the second test — notice the exact sequence of click, wait, and assertion steps.

## Step 3 — Introduce a Deliberate Failure

Change the assertion in the navigation test to expect the wrong screen name:

```robot
    Wait Until Element Contains    id:nav-current-screen    MEDIA    timeout=3s
```

Run again. The test fails. Open `log.html`:

- The red keyword shows the actual value (`CLIMATE`) versus what was expected (`MEDIA`)
- All keywords *before* the failure are green — you can see exactly how far execution got
- The `[Teardown]` keyword at the end is still green — teardown runs even after failure

This is the core debugging workflow. You will use `log.html` this way throughout every tutorial.

**Revert the change** before continuing.

## Step 4 — Add a BDD-Style Test

Robot Framework supports Gherkin-style naming without any special plugin. `Given`, `When`, and `Then` are simply part of the keyword name — Robot Framework strips the prefix when resolving them.

Add this test:

```robot
*** Test Cases ***
Settings Screen Is Reachable From Home
    Given the simulator is open
    When the user opens settings
    Then the settings screen is visible
    [Teardown]    Close Browser

*** Keywords ***
the simulator is open
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=5s

the user opens settings
    Click Button    id:app-icon-settings

the settings screen is visible
    Wait Until Element Is Visible    id:screen-settings    timeout=3s
    Element Text Should Be    id:nav-current-screen    SETTINGS
```

Run:

```powershell
robot -d results tests/01_first_test.robot
```

Notice: the test body reads like a specification. The technical steps (`Open Browser`, `Click Button`, `Wait Until Element Is Visible`) are hidden inside keywords.

## What You Learned

| Concept | Where you saw it |
| --- | --- |
| Library import | `Library    SeleniumLibrary` |
| Variable declaration | `${SIMULATOR_URL}    file://...` |
| Real assertions | `Element Text Should Be`, `Element Should Be Visible` |
| Teardown | `[Teardown]    Close Browser` — runs even after failure |
| Reading log.html | Expanding the red keyword to find the actual vs expected value |
| BDD style | `Given / When / Then` as keyword name prefixes |

## What Each Run Produces

```text
results/
├── output.xml     raw execution data (used by CI and rebot)
├── log.html       keyword-level detail — your primary debugging tool
└── report.html    pass/fail summary by suite and tag
```

## Practice Challenge

Add a fourth test case that:

1. Opens the simulator
2. Clicks the **Navigation** app icon
3. Types a destination into `id:nav-destination-input`
4. Clicks `id:nav-search-button`
5. Asserts that `id:nav-destination-display` no longer contains `---`

Run it, confirm it passes, then deliberately break one assertion and read the failure in `log.html`.
