*** Settings ***
Documentation    Tutorial for Robot Framework features and libraries.
Library          Collections
Library          String
Library          DateTime
Library          ../libraries/NumberTools.py

*** Test Cases ***
Use Standard Libraries
    ${items}=    Create List    navigation    media    climate
    Append To List    ${items}    settings
    Length Should Be    ${items}    4

    ${title}=    Convert To Title Case    robot framework
    Should Be Equal    ${title}    Robot Framework

    ${today}=    Get Current Date    result_format=%Y-%m-%d
    Should Match Regexp    ${today}    \\d{4}-\\d{2}-\\d{2}

Add Item To Shopping Cart
    Open Product Page    shoes
    Select Size          42
    Click Add To Cart
    Cart Should Contain  shoes    quantity=1

Use A Custom Number Library
    ${even}=    Is Even    42
    Should Be True    ${even}

    ${odd}=    Is Even    41
    Should Not Be True    ${odd}

*** Keywords ***
Open Product Page
    [Arguments]    ${product}
    Log    Opening product page for ${product}.

Select Size
    [Arguments]    ${size}
    Should Be True    ${size} > 0
    Log    Selected size ${size}.

Click Add To Cart
    Log    Clicked Add To Cart.

Cart Should Contain
    [Arguments]    ${product}    ${quantity}
    Should Be Equal    ${product}    shoes
    Should Be Equal As Integers    ${quantity}    1
