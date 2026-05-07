*** Settings ***
Documentation    Tutorial 04 — ${CURDIR} vs ${EXECDIR}: why resource paths break and how to fix them.
...              Run from project root and again from inside learning-lab/tests/ and compare logs.
Library          OperatingSystem
Resource         ${CURDIR}/../resources/common.resource

*** Test Cases ***
Show CURDIR vs EXECDIR
    [Documentation]    ${CURDIR} follows the file; ${EXECDIR} follows the terminal.
    ...                Run from different directories and inspect the logged paths in log.html.
    [Tags]    config    tutorial-04
    Log    CURDIR (file location): ${CURDIR}
    Log    EXECDIR (invocation dir): ${EXECDIR}
    Log    SIMULATOR_URL: ${SIMULATOR_URL}
    Should Contain    ${CURDIR}    tests
    ...    msg=CURDIR should contain 'tests' — it tracks the file, not the terminal

Portable Resource Import Works
    [Documentation]    The common.resource was imported with ${CURDIR} — it resolves correctly.
    [Tags]    config    smoke    tutorial-04
    Should Not Be Empty    ${SIMULATOR_URL}
    Should Not Be Empty    ${BROWSER}
    Log    Simulator URL resolved to: ${SIMULATOR_URL}

Simulator File Is Accessible From This Path
    [Documentation]    The URL built from EXECDIR points to a real file.
    [Tags]    config    smoke    tutorial-04
    ${file_path}=    Set Variable    ${EXECDIR}/simulator/index.html
    File Should Exist    ${file_path}
    ...    msg=Run robot from the project root so ${EXECDIR} points to it.
