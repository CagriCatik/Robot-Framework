*** Settings ***
Documentation    First Robot Framework tutorial suite.
Library          ../libraries/TextTools.py

*** Test Cases ***
Robot Can Run A Simple Test
    Log    Hello from Robot Framework
    Should Be Equal    Robot    Robot

Robot Can Use A Business-Like Keyword
    Given A Learner Has Robot Framework
    When The Learner Runs A Test
    Then A Report Is Created

Keyword Driven Search Example
    Open Search Page
    Search For Product    laptop
    Search Results Should Contain    laptop

Data Driven Login Example
    [Template]    Login Attempt Should Produce Message
    wrong_user    correct_password    Invalid username or password
    admin         wrong_password      Invalid username or password
    ${EMPTY}      ${EMPTY}            Username is required

BDD Style Example
    Given the app is available
    When the user opens the dashboard
    Then dashboard widgets are visible

Use A Custom Python Library
    ${label}=    Normalize Label    climate control
    Should Be Equal    ${label}    Climate Control

    ${found}=    Contains Ignore Case    Robot Framework Guide    framework
    Should Be True    ${found}

*** Keywords ***
Given A Learner Has Robot Framework
    Log    Robot Framework is installed.

When The Learner Runs A Test
    Log    The robot command executes the suite.

Then A Report Is Created
    Log    Robot writes output.xml, log.html, and report.html.

Open Search Page
    Log    Opening the search page.

Search For Product
    [Arguments]    ${product}
    Log    Searching for ${product}.

Search Results Should Contain
    [Arguments]    ${expected}
    Should Contain    Results for laptop    ${expected}

Login Attempt Should Produce Message
    [Arguments]    ${username}    ${password}    ${expected_message}
    Log    Trying username=${username}, password=${password}
    Should Not Be Empty    ${expected_message}

Given the app is available
    Log    The application is reachable.

When the user opens the dashboard
    Log    Opening dashboard.

Then dashboard widgets are visible
    Log    Dashboard widgets are visible.
