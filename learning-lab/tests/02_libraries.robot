*** Settings ***
Documentation    Tutorial 02 — SeleniumLibrary for UI, BuiltIn/Collections for data, custom Python lib.
...              Teaches: library types, FOR loops, return values, custom keywords.

Library          Collections
Library          String
Library          ${CURDIR}/../libraries/TemperatureUtils.py
Resource         ${CURDIR}/../resources/common.resource

*** Test Cases ***
Climate Temperature Can Be Raised
    [Documentation]    Reading a live DOM value, clicking three times, asserting the change.
    [Tags]    climate    library    tutorial-02
    Open Simulator
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    ${before}=    Get Text    id:climate-temperature-value
    Click Button    id:climate-temp-up
    Click Button    id:climate-temp-up
    Click Button    id:climate-temp-up
    ${after}=    Get Text    id:climate-temperature-value
    Should Not Be Equal    ${before}    ${after}
    [Teardown]    Close Browser

Fan Speed Can Be Iterated To Target
    [Documentation]    FOR loop with early exit — stops clicking when display reaches 5.
    [Tags]    climate    library    tutorial-02
    Open Simulator
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    FOR    ${i}    IN RANGE    10
        ${speed}=    Get Text    id:climate-fan-speed-value
        Exit For Loop If    '${speed}' == '5'
        Click Button    id:climate-fan-up
    END
    ${final}=    Get Text    id:climate-fan-speed-value
    Should Be Equal    ${final}    5
    [Teardown]    Close Browser

Temperature Value Is Within Operational Range
    [Documentation]    Custom Python library parses "22°C" and validates the numeric range.
    [Tags]    climate    library    custom-lib    tutorial-02
    Open Simulator
    Click Button    id:app-icon-climate
    Wait Until Element Is Visible    id:screen-climate    timeout=3s
    ${raw}=    Get Text    id:climate-temperature-value
    ${in_range}=    Temperature Is In Range    ${raw}    16    30
    Should Be True    ${in_range}
    ...    Temperature ${raw} is outside the valid 16–30°C range
    ${fahrenheit}=    Celsius To Fahrenheit    ${raw}
    Log    Driver temperature: ${raw} = ${fahrenheit}°F
    [Teardown]    Close Browser

App Screen List Can Be Validated
    [Documentation]    Collections library — build a list and assert length.
    [Tags]    library    tutorial-02
    @{screens}=    Create List    navigation    media    climate    phone    vehicle    settings    camera    weather
    Length Should Be    ${screens}    8
    Should Be Equal    ${screens}[0]    navigation
    Should Be Equal    ${screens}[-1]    weather
