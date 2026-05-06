*** Settings ***
Documentation    Section 03 with practical checks for the environment needed by the tutorial project.
Resource         ../resources/common.resource
Resource         ../resources/simulator_ui.resource
Library          Process
Test Tags        section-03    installation

*** Test Cases ***
Robot Framework Is Installed In The Active Python
    [Tags]    smoke
    ${version}=    Get Robot Version
    Should Match Regexp    ${version}    \\d+\\.\\d+(\\.\\d+)?

Current Python Can Import Robot Framework
    ${python}=    Get Python Executable
    ${result}=    Run Process    ${python}    -c    import robot; print(robot.__version__)
    Should Be Equal As Integers    ${result.rc}    0
    Should Match Regexp    ${result.stdout}    \\d+\\.\\d+(\\.\\d+)?

Simulator Target File Exists And Can Be Converted To A Browser URL
    ${simulator_path}=    Normalize Path    ${CURDIR}/../../../simulator/index.html
    File Should Exist    ${simulator_path}
    ${simulator_url}=    Get File Uri    ${simulator_path}
    Should Start With    ${simulator_url}    file:///

Project Dependencies Used By Realistic Suites Are Importable
    Environment Should Have Required Keys    dev
    ${python}=    Get Python Executable
    ${result}=    Run Process    ${python}    -c    import SeleniumLibrary; print("ok")
    Should Be Equal As Integers    ${result.rc}    0
    Should Contain    ${result.stdout}    ok

