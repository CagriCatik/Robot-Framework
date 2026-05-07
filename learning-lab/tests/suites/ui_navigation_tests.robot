*** Settings ***
Documentation    Tutorial 07 — Nested folder suite example.
...              Shows how a subdirectory creates a child suite in Robot Framework.
...              This file intentionally covers both navigation and phone screens
...              to demonstrate that a suite can test multiple related features.

Resource         ${CURDIR}/../../resources/navigation_page.resource

Suite Setup      Open Navigation Screen
Suite Teardown   Close All Browsers
Test Setup       Go To Home Screen
Test Teardown    Capture Screenshot On Failure

Test Tags    ui    nested    tutorial-07

*** Test Cases ***
Navigation Screen Opens From Home
    [Tags]    smoke
    Click Button    id:app-icon-navigation
    Wait Until Element Is Visible    id:screen-navigation    timeout=3s
    Current Screen Should Be    navigation

Navigation Search Returns A Destination
    [Tags]    navigation
    Click Button    id:app-icon-navigation
    Wait Until Element Is Visible    id:screen-navigation    timeout=3s
    Search For Destination    Hamburg Airport
    Destination Should Be    Hamburg Airport
    ETA Should Be Available

Phone Screen Opens From Home
    [Tags]    phone
    Open Phone Screen
    Current Screen Should Be    phone

Phone Bluetooth Toggle Changes State
    [Tags]    phone    toggle
    Open Phone Screen
    Phone Bluetooth Toggle Should Change State
