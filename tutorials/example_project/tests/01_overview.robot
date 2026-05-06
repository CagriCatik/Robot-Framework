*** Settings ***
Documentation     Section 01 as a realistic smoke suite for the infotainment simulator.
Resource          ../resources/simulator_ui.resource
Suite Setup       Open Tutorial Simulator
Suite Teardown    Close Tutorial Simulator
Test Setup        Go To Home Screen
Test Tags         section-01    overview    simulator

*** Test Cases ***
Simulator Boots To A Usable Home Screen
    [Tags]    smoke    keyword-driven
    Given The Simulator Has Booted
    When The Home Screen Is Displayed
    Then Core Application Icons Are Available

Main Applications Can Open From Home
    [Tags]    navigation    data-driven
    [Template]    Simulator App Should Open
    navigation
    media
    climate
    vehicle
    settings
    camera

BDD Style Scenario Uses Real UI State
    [Tags]    bdd-style
    Given the simulator home screen is open
    When the driver opens the media app
    Then the media screen is shown

*** Keywords ***
Given The Simulator Has Booted
    Status Bar Should Be Complete

When The Home Screen Is Displayed
    Current Simulator Screen Should Be    home

Then Core Application Icons Are Available
    Home Screen App Icons Should Be Visible

Simulator App Should Open
    [Arguments]    ${app_name}
    Open Simulator App    ${app_name}
    Current Simulator Screen Should Be    ${app_name}
    Go To Home Screen

Given the simulator home screen is open
    Current Simulator Screen Should Be    home

When the driver opens the media app
    Open Simulator App    media

Then the media screen is shown
    Current Simulator Screen Should Be    media

