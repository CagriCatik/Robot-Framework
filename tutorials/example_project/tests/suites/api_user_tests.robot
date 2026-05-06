*** Settings ***
Documentation    Nested API suite example.
Resource         ../../resources/api_helpers.resource
Test Tags        api    nested

*** Test Cases ***
Nested API Suite Can Reuse Shared Resources
    [Tags]    smoke
    Create Tutorial API Session
    ${response}=    Get Users From Tutorial API
    Response Should Contain Users    ${response}    2

