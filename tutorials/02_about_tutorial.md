# Tutorial 02 — Libraries: SeleniumLibrary, BuiltIn, and Your Own Python Code

## The Scenario

You need three different types of automation against the simulator:

1. **UI testing** — click buttons, read text, verify screen state (SeleniumLibrary)
2. **Data processing** — parse and transform values returned from the UI (standard BuiltIn / Collections)
3. **Custom logic** — a small Python library for domain-specific calculations that Robot syntax makes awkward

This tutorial shows all three in the same project so you can see where each type of library fits.

## Library Types at a Glance

| Type | Where it comes from | Installed how | Example |
| --- | --- | --- | --- |
| Standard | Bundled with Robot Framework | Nothing extra | `BuiltIn`, `Collections`, `String` |
| External | Community or vendor package | `pip install …` | `SeleniumLibrary`, `RequestsLibrary` |
| Custom | Written by your team | File in `libraries/` | `TemperatureUtils.py` |

## Part 1 — SeleniumLibrary for UI Interaction

SeleniumLibrary wraps Selenium WebDriver. Every keyword maps to a browser action or assertion.

Create `tests/02_libraries.robot`:

```robot
*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${SIMULATOR_URL}    file:///${EXECDIR}/simulator/index.html
${BROWSER}          chrome

*** Test Cases ***
Climate Temperature Can Be Raised
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=5s

    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s

    # Read the current temperature before touching anything
    ${temp_before}=    Get Text    id:climate-temperature-value

    # Click up three times
    Click Button    id:climate-temp-up
    Click Button    id:climate-temp-up
    Click Button    id:climate-temp-up

    # Read the new value
    ${temp_after}=    Get Text    id:climate-temperature-value

    # They must differ
    Should Not Be Equal    ${temp_before}    ${temp_after}

    [Teardown]    Close Browser
```

Run:

```powershell
robot -d results tests/02_libraries.robot
```

Open `log.html`. Expand `Get Text` — you can see the exact string it returned. This is what TRACE-level logging looks like without having to set `--loglevel TRACE`.

## Part 2 — BuiltIn and Collections for Data Work

The temperature value comes back as a string like `"22°C"`. If you need the number for arithmetic, you have to extract it. BuiltIn and String libraries handle this cleanly.

Add a second test to `tests/02_libraries.robot`:

```robot
*** Settings ***
Library    Collections
Library    String

*** Test Cases ***
Fan Speed List Can Be Iterated
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s

    # Click fan up until the display reads 5
    FOR    ${i}    IN RANGE    10
        ${speed}=    Get Text    id:climate-fan-speed-value
        Exit For Loop If    '${speed}' == '5'
        Click Button    id:climate-fan-up
    END

    ${final}=    Get Text    id:climate-fan-speed-value
    Should Be Equal    ${final}    5

    # Build a list of the toggle labels and verify they are all uppercase
    @{toggles}=    Create List    A/C ON    SYNC OFF    DEFROST OFF    RECIRC OFF
    FOR    ${label}    IN    @{toggles}
        ${upper}=    Convert To Upper Case    ${label}
        Should Be Equal    ${label}    ${upper}
    END

    [Teardown]    Close Browser
```

Run again. This test shows a FOR loop with an early exit — something that is useful when you cannot predict exactly how many clicks are needed.

## Part 3 — A Custom Python Library

Some logic does not belong in Robot syntax. Temperature unit conversion is a perfect example — the math is simple but expressing it with `Evaluate` inside `.robot` gets noisy.

Create `libraries/TemperatureUtils.py`:

```python
class TemperatureUtils:
    """Utility keywords for temperature assertions in the simulator tests."""

    def celsius_to_fahrenheit(self, celsius_str):
        """Converts '22°C' to 71.6 (float)."""
        value = float(celsius_str.replace("°C", "").strip())
        return round(value * 9 / 5 + 32, 1)

    def temperature_is_in_range(self, celsius_str, low, high):
        """Returns True if the temperature value is between low and high (inclusive)."""
        value = float(celsius_str.replace("°C", "").strip())
        return float(low) <= value <= float(high)

    def parse_temperature(self, celsius_str):
        """Returns the numeric part of '22°C' as a float."""
        return float(celsius_str.replace("°C", "").strip())
```

Add a third test to `tests/02_libraries.robot`:

```robot
*** Settings ***
Library    ../libraries/TemperatureUtils.py

*** Test Cases ***
Temperature Value Is Within Operational Range
    Open Browser    ${SIMULATOR_URL}    ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    id:screen-home    timeout=5s
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s

    ${raw}=    Get Text    id:climate-temperature-value

    # Use the custom library to validate the value
    ${in_range}=    Temperature Is In Range    ${raw}    16    30
    Should Be True    ${in_range}    Temperature ${raw} is outside the valid 16–30°C range

    # Convert and log for reporting purposes
    ${fahrenheit}=    Celsius To Fahrenheit    ${raw}
    Log    Driver temperature: ${raw} = ${fahrenheit}°F

    [Teardown]    Close Browser
```

Run:

```powershell
robot -d results tests/02_libraries.robot
```

The logged message — `Driver temperature: 22°C = 71.6°F` — appears in `log.html` under the `Log` keyword. Custom library keywords are indistinguishable from built-in ones in both the test file and the log.

## Why This Architecture Matters

- **SeleniumLibrary** drives the browser. Your tests do not call WebDriver directly.
- **Standard libraries** handle data manipulation (string parsing, list operations, math).
- **Custom libraries** encapsulate domain rules that would require multiple `Evaluate` calls if written in Robot syntax.

The `.robot` file stays readable because the mechanics live elsewhere.

## Common Mistake: Mixing Concerns in the Test

Avoid this:

```robot
# BAD — raw Selenium + string hacks inside the test case
${raw}=    Get Text    id:climate-temperature-value
${num}=    Evaluate    float("${raw}".replace("°C","").strip())
Should Be True    16 <= ${num} <= 30
```

Do this instead — the assertion reads as business intent, the parsing is in Python:

```robot
# GOOD
${raw}=    Get Text    id:climate-temperature-value
${in_range}=    Temperature Is In Range    ${raw}    16    30
Should Be True    ${in_range}
```

## Practice Challenge

Add a keyword `parse_fan_speed` to `TemperatureUtils.py` that takes the string `"3"` from `id:climate-fan-speed-value` and returns it as an integer.

Write a test that:

1. Opens the climate screen
2. Clicks fan up twice
3. Reads `id:climate-fan-speed-value`
4. Calls `Parse Fan Speed` and asserts the result is greater than or equal to the initial speed plus 2
