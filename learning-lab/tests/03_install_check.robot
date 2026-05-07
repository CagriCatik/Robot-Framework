*** Settings ***
Documentation    Tutorial 03 — Verify the environment before writing real tests.
...              Run this after setting up a new machine or virtual environment.
...              All four tests must pass for the rest of the tutorials to work.

Library          OperatingSystem
Resource         ${CURDIR}/../resources/common.resource

*** Test Cases ***
Robot Framework Version Is 6 Or Newer
    [Documentation]    RF 6+ is required for Test Tags, RETURN, and TRY/EXCEPT.
    [Tags]    env    smoke    tutorial-03
    ${version}=    Evaluate
    ...    int(__import__('robot').version.VERSION.split('.')[0])
    ...    modules=robot
    Should Be True    ${version} >= 6
    ...    Robot Framework version must be 6 or newer. Found version ${version}.

SeleniumLibrary Is Importable
    [Documentation]    Confirms SeleniumLibrary was installed in the active virtual environment.
    [Tags]    env    smoke    tutorial-03
    ${lib}=    Evaluate    __import__('SeleniumLibrary')    modules=SeleniumLibrary
    Should Not Be Equal    ${lib}    ${None}

Simulator File Exists At Expected Path
    [Documentation]    The simulator HTML file must be present relative to the project root.
    ...                Run this from the project root: robot -d learning-lab/results learning-lab/tests/
    [Tags]    env    smoke    tutorial-03
    ${path}=    Set Variable    ${EXECDIR}/simulator/index.html
    File Should Exist    ${path}
    ...    msg=Simulator not found at ${path}. Run robot from the project root directory.

Browser Can Open The Simulator And Read The Title
    [Documentation]    End-to-end smoke: Chrome opens, simulator loads, home screen is visible.
    [Tags]    env    smoke    browser    tutorial-03
    Open Simulator
    ${title}=    Get Title
    Should Contain    ${title}    AutoCenter
    ...    msg=Expected page title to contain 'AutoCenter'. Got: ${title}
    Element Should Be Visible    id:screen-home
    [Teardown]    Close Browser
