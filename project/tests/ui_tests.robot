*** Settings ***
Resource          ../resources/common.resource
Test Teardown     Close My Browser
Documentation     A simple UI test suite to demonstrate Google Search.

*** Test Cases ***
Verify Google Search Works
    [Tags]    ui    smoke
    Open Browser To Google
    Search For Robot Framework    Robot Framework
    Page Should Contain    Robot Framework
