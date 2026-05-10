# Robot Framework Cheat Sheet

Aktuelle Referenz: Robot Framework User Guide 7.4.2. Die wichtigsten CLI-Werkzeuge sind `robot` für Testausführung und `rebot` für Nachbearbeitung von Outputs. ([robotframework.org][1])

---

## 1. Installation & Version

```bash
pip install robotframework
robot --version
robot --help
```

Optional häufige Libraries:

```bash
pip install robotframework-seleniumlibrary
pip install robotframework-requests
```

---

## 2. Tests ausführen

```bash
robot tests/
robot tests/login.robot
robot path/to/suite.robot
```

Mit Output-Verzeichnis:

```bash
robot --outputdir results tests/
```

Mit eigenem Suite-Namen:

```bash
robot --name "Smoke Tests" tests/
```

Nur bestimmte Tests:

```bash
robot --test "Login With Valid User" tests/
```

Nur bestimmte Suite:

```bash
robot --suite "Login Suite" tests/
```

---

## 3. Tags verwenden

Tests mit Tag ausführen:

```bash
robot --include smoke tests/
robot -i smoke tests/
```

Tests mit Tag ausschließen:

```bash
robot --exclude slow tests/
robot -e slow tests/
```

Mehrere Tags:

```bash
robot --include smoke --include regression tests/
robot --exclude unstable --exclude wip tests/
```

Tag setzen zur Laufzeit:

```bash
robot --settag ci tests/
```

---

## 4. Variablen übergeben

Einzelne Variable:

```bash
robot --variable BROWSER:chrome tests/
robot -v ENV:dev tests/
```

Mehrere Variablen:

```bash
robot -v BROWSER:chrome -v BASE_URL:https://example.com tests/
```

Variable File:

```bash
robot --variablefile variables.py tests/
robot -V variables.py tests/
```

---

## 5. Output-Dateien

Standardmäßig erzeugt Robot Framework:

```text
output.xml
log.html
report.html
```

Eigene Namen:

```bash
robot --output output.xml --log log.html --report report.html tests/
```

Nur XML erzeugen, keine HTML-Dateien:

```bash
robot --log NONE --report NONE tests/
```

Eigenes Output-Verzeichnis:

```bash
robot -d results tests/
```

---

## 6. Log Level

```bash
robot --loglevel DEBUG tests/
robot --loglevel INFO tests/
robot --loglevel WARN tests/
robot --loglevel ERROR tests/
```

Trace-Level für Debugging:

```bash
robot --loglevel TRACE tests/
```

---

## 7. Dry Run / Syntax prüfen

Prüft Tests ohne echte Ausführung:

```bash
robot --dryrun tests/
```

Nützlich für CI, wenn du nur Syntax, Imports und Keyword-Auflösung prüfen willst.

---

## 8. Rebot: Reports nachträglich erzeugen

Aus `output.xml` neue Reports bauen:

```bash
rebot output.xml
```

Mit Zielordner:

```bash
rebot --outputdir results output.xml
```

Mehrere Outputs zusammenführen:

```bash
rebot --merge output1.xml output2.xml
```

Reports ohne erneute Testausführung erzeugen:

```bash
rebot --log log.html --report report.html output.xml
```

---

# 9. Parallel ausführen mit Pabot

Pabot ist nicht Teil des Kernpakets, wird aber oft für parallele Ausführung verwendet.

```bash
pip install robotframework-pabot
pabot tests/
pabot --processes 4 tests/
pabot --outputdir results tests/
```

---

## 10. Typische `.robot` Datei

```robot
*** Settings ***
Library    SeleniumLibrary
Resource   resources/common.resource
Suite Setup       Open Browser To App
Suite Teardown    Close Browser

*** Variables ***
${BASE_URL}    https://example.com
${BROWSER}     chrome

*** Test Cases ***
Valid Login
    [Tags]    smoke    login
    Open Login Page
    Input Username    demo
    Input Password    secret
    Submit Login
    Page Should Contain    Welcome

*** Keywords ***
Open Browser To App
    Open Browser    ${BASE_URL}    ${BROWSER}

Open Login Page
    Go To    ${BASE_URL}/login
```

---

## 11. Sections

```robot
*** Settings ***
*** Variables ***
*** Test Cases ***
*** Tasks ***
*** Keywords ***
*** Comments ***
```

Häufige Settings:

```robot
Library           SeleniumLibrary
Resource          common.resource
Variables         variables.py
Suite Setup       Setup Suite
Suite Teardown    Teardown Suite
Test Setup        Setup Test
Test Teardown     Teardown Test
Test Template     Login Should Behave Correctly
Documentation     Suite documentation here
```

---

# 12. Variablen

Scalar:

```robot
${USER}    demo
```

List:

```robot
@{BROWSERS}    chrome    firefox    edge
```

Dictionary:

```robot
&{USER_DATA}    username=demo    password=secret
```

Verwendung:

```robot
Log    ${USER}
Log Many    @{BROWSERS}
Log    ${USER_DATA}[username]
```

---

## 13. IF / ELSE

```robot
IF    ${status} == 200
    Log    Success
ELSE IF    ${status} == 404
    Log    Not found
ELSE
    Fail    Unexpected status
END
```

---

# 14. FOR Loop

```robot
FOR    ${item}    IN    one    two    three
    Log    ${item}
END
```

Mit Liste:

```robot
FOR    ${browser}    IN    @{BROWSERS}
    Log    ${browser}
END
```

---

## 15. WHILE Loop

```robot
WHILE    ${counter} < 5
    Log    ${counter}
    ${counter}=    Evaluate    ${counter} + 1
END
```

---

# 16. TRY / EXCEPT

```robot
TRY
    Click Button    Submit
EXCEPT
    Log    Button click failed
    Capture Page Screenshot
END
```

---

## 17. Keyword mit Argumenten

```robot
*** Keywords ***
Login With User
    [Arguments]    ${username}    ${password}
    Input Text    id=username    ${username}
    Input Text    id=password    ${password}
    Click Button  id=login
```

Aufruf:

```robot
Login With User    demo    secret
```

---

## 18. Return Values

```robot
*** Keywords ***
Get Full Name
    [Arguments]    ${first}    ${last}
    ${name}=    Set Variable    ${first} ${last}
    RETURN    ${name}
```

Aufruf:

```robot
${full_name}=    Get Full Name    Max    Mustermann
```

---

## 19. Setup & Teardown

Pro Test:

```robot
*** Test Cases ***
Example Test
    [Setup]       Open Browser
    [Teardown]    Close Browser
    Log           Running test
```

Für ganze Suite:

```robot
*** Settings ***
Suite Setup       Start System
Suite Teardown    Stop System
Test Setup        Prepare Test
Test Teardown     Cleanup Test
```

---

## 20. Nützliche BuiltIn Keywords

```robot
Log    Hello
Log To Console    Hello terminal
Should Be Equal    ${a}    ${b}
Should Contain    ${text}    expected
Should Be True    ${value}
Fail    Error message
Sleep    2s
Set Variable    value
Evaluate    1 + 2
Run Keyword If    ${condition}    Keyword Name
Run Keyword And Ignore Error    Keyword Name
Wait Until Keyword Succeeds    5x    2s    Keyword Name
```

---

## 21. Häufige CLI-Kommandos für CI

Smoke Tests:

```bash
robot -d results -i smoke tests/
```

Regression ohne instabile Tests:

```bash
robot -d results -i regression -e unstable tests/
```

Mit Browser und Environment:

```bash
robot -d results -v BROWSER:chrome -v ENV:staging tests/
```

Dry Run im Pull Request:

```bash
robot --dryrun -d results tests/
```

Nur fehlgeschlagene Tests erneut ausführen:

```bash
robot --rerunfailed results/output.xml --output rerun.xml tests/
rebot --merge results/output.xml rerun.xml
```

---

## 22. Mini-Projektstruktur

```text
project/
├── tests/
│   ├── login.robot
│   └── checkout.robot
├── resources/
│   ├── common.resource
│   └── keywords.resource
├── variables/
│   └── dev.py
└── results/
```

Typischer Run:

```bash
robot -d results -V variables/dev.py tests/
```

---

## 23. Schnellreferenz

| Zweck                  | Command                                 |
| ---------------------- | --------------------------------------- |
| Alle Tests starten     | `robot tests/`                          |
| Einzelne Datei starten | `robot tests/login.robot`               |
| Output-Ordner setzen   | `robot -d results tests/`               |
| Nur Tag ausführen      | `robot -i smoke tests/`                 |
| Tag ausschließen       | `robot -e slow tests/`                  |
| Variable setzen        | `robot -v BROWSER:chrome tests/`        |
| Dry Run                | `robot --dryrun tests/`                 |
| Report neu bauen       | `rebot output.xml`                      |
| Outputs mergen         | `rebot --merge output1.xml output2.xml` |
| Parallel mit Pabot     | `pabot --processes 4 tests/`            |

[1]: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html"Robot Framework User Guide"
