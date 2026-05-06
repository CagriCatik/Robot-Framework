# About Robot Framework

Robot Framework distinguishes itself from other automation tools through its design philosophy and technical architecture.

## Key Features

### 1. Keyword-Driven Automation

Robot Framework uses a **keyword-driven** approach. Test cases are written using human-readable keywords rather than complex code.

- **Keywords**: Conceptually similar to methods in programming languages.
- **Readability**: Makes tests easy to write and understand for both developers and non-technical stakeholders.

```robot
*** Test Cases ***
Add Item To Shopping Cart
    Open Product Page    shoes
    Select Size          42
    Click Add To Cart
    Cart Should Contain    shoes    quantity=1
```

Each line in the test body is a keyword call. Keywords hide implementation details so the test reads as a business specification.

### 2. Platform and Application Independence

Because the core framework is implemented in **Python**, it is independent of the operating system and the application under test. It runs on any environment that supports Python (Windows, macOS, Linux).

### 3. Extensibility through Libraries

The power of Robot Framework can be extended using libraries, which can be written in **Python** or **Java**.

#### Library Types

| Type | Description | Examples |
| ---- | ----------- | ------- |
| **Standard** | Bundled with the framework, no install needed | `BuiltIn`, `OperatingSystem`, `Collections`, `String`, `DateTime` |
| **External** | Community-maintained, installed via pip | `SeleniumLibrary`, `RequestsLibrary`, `AppiumLibrary`, `Browser` |
| **Custom** | Written by your team for project-specific logic | Any Python class or module |

#### Standard Library Highlights

```robot
*** Settings ***
Library    Collections
Library    String
Library    DateTime
Library    OperatingSystem

*** Test Cases ***
Standard Library Examples
    # Collections
    ${my_list}=    Create List    apple    banana    cherry
    Append To List    ${my_list}    date
    Length Should Be    ${my_list}    4

    # String
    ${upper}=    Convert To Upper Case    hello world
    Should Be Equal    ${upper}    HELLO WORLD

    # DateTime
    ${now}=    Get Current Date    result_format=%Y-%m-%d
    Log    Today is ${now}

    # OperatingSystem
    File Should Exist    /etc/hosts
    ${content}=    Get File    /etc/hosts
```

#### External Library Example — SeleniumLibrary

This project uses `robotframework-seleniumlibrary` (see `requirements-rf.txt`).

```robot
*** Settings ***
Library    SeleniumLibrary

*** Test Cases ***
Web Login Test
    Open Browser    https://example.com/login    chrome
    Maximize Browser Window
    Input Text      id:username    admin
    Input Password  id:password    secret
    Click Button    id:login-btn
    Title Should Be    Dashboard
    [Teardown]    Close Browser
```

#### External Library Example — RequestsLibrary

```robot
*** Settings ***
Library    RequestsLibrary

*** Test Cases ***
GET Users From API
    Create Session    jsonplaceholder    https://jsonplaceholder.typicode.com
    ${response}=    GET On Session    jsonplaceholder    /users
    Should Be Equal As Integers    ${response.status_code}    200
    ${users}=    Evaluate    $response.json()
    Length Should Be    ${users}    10
```

#### Custom Python Library Example

```python
# libraries/DateUtils.py
from datetime import datetime

class DateUtils:
    """Custom library for date-related helpers."""

    def get_formatted_today(self, fmt="%Y-%m-%d"):
        """Returns today's date in the given format."""
        return datetime.now().strftime(fmt)

    def is_weekend(self):
        """Returns True if today is Saturday or Sunday."""
        return datetime.now().weekday() >= 5
```

Import it in your test suite:

```robot
*** Settings ***
Library    ../libraries/DateUtils.py

*** Test Cases ***
Check Today Is Not Weekend
    ${weekend}=    Is Weekend
    Should Not Be True    ${weekend}
```

## Robot Framework 6.x Features

This project targets Robot Framework 6.x (`robotframework>=6.1.1`). Key features available:

### `TRY / EXCEPT` — Structured Error Handling

```robot
*** Test Cases ***
Handle API Failure Gracefully
    TRY
        ${resp}=    GET On Session    my_api    /endpoint
        Should Be Equal As Integers    ${resp.status_code}    200
    EXCEPT    Connection refused*    type=glob
        Log    API is unavailable — skipping test    WARN
    END
```

### `WHILE` Loop

```robot
*** Keywords ***
Wait Until Element Disappears
    [Arguments]    ${locator}    ${timeout}=30
    ${end_time}=    Evaluate    time.time() + ${timeout}    modules=time
    WHILE    True    limit=30
        ${visible}=    Run Keyword And Return Status    Element Should Be Visible    ${locator}
        IF    not ${visible}    RETURN
        Sleep    1s
    END
```

### Inline `IF`

```robot
*** Keywords ***
Log Environment
    [Arguments]    ${env}
    Log    ${env == 'prod'}    # inline IF can be used in VAR and RETURN
    ${label}=    Set Variable If    '${env}' == 'prod'    PRODUCTION    STAGING
    Log    Running on: ${label}
```

### `VAR` Syntax (RF 7.x preview)

```robot
*** Test Cases ***
VAR Example
    VAR    ${greeting}    Hello, World!
    Log    ${greeting}
```

## Ecosystem

The framework provides a robust ecosystem including:

- **RIDE**: The Robot Framework IDE — a standalone GUI editor for `.robot` files.
- **Pabot**: Parallel executor for Robot Framework tests.
- **RF-Dashboard / Allure**: Enhanced reporting plugins.
- **robocop**: Static analysis and linting tool for Robot Framework.
- **robotidy**: Automatic code formatter for `.robot` and `.resource` files.
- **CI/CD Integration**: Native support in Jenkins, GitHub Actions, GitLab CI, and Azure DevOps via the `output.xml` result format.

---

*Next: [Installation Guide](03_installation.md)*
