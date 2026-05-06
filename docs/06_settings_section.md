# The Settings Section

The `*** Settings ***` section is the control hub of your Robot Framework file. It tells the framework which tools to use, what metadata to include, and how to manage the test lifecycle.

## Key Settings

### 1. Library

Used to import standard or external libraries. Library names are case-sensitive and must match the installed package exactly.

```robot
*** Settings ***
Library    OperatingSystem
Library    SeleniumLibrary
Library    RequestsLibrary
Library    Collections
```

#### Library Aliasing (`WITH NAME`)

If you need to import two libraries that share keyword names, use `WITH NAME` to assign an alias:

```robot
*** Settings ***
Library    mypackage.module.DateUtils    WITH NAME    DateUtils
Library    anotherpackage.DateUtils      WITH NAME    AltDateUtils
```

Call keywords using the alias prefix:

```robot
*** Test Cases ***
Alias Example
    ${d1}=    DateUtils.Get Current Date
    ${d2}=    AltDateUtils.Get Current Date
```

#### Library with Arguments

Some libraries accept constructor arguments:

```robot
*** Settings ***
Library    SeleniumLibrary    timeout=10    implicit_wait=0    run_on_failure=Capture Page Screenshot
```

### 2. Resource

Used to import external `.resource` files containing shared keywords and variables.

```robot
*** Settings ***
Resource    ../resources/common.resource
Resource    ../resources/login_page.resource
```

Paths are relative to the file containing the `Resource` setting. Use `${CURDIR}` for paths that must be portable:

```robot
*** Settings ***
Resource    ${CURDIR}/../resources/common.resource
```

### 3. Variables

Imports an external **variable file** (a Python module or YAML file that defines variables).

```robot
*** Settings ***
Variables    ../data/config.py
Variables    ../data/test_users.yaml
```

Python variable file example (`data/config.py`):

```python
BASE_URL = "https://example.com"
BROWSER = "chrome"
TIMEOUT = 10
```

YAML variable file example (`data/test_users.yaml`):

```yaml
ADMIN_USER:
  username: admin
  password: secret

READONLY_USER:
  username: viewer
  password: viewonly
```

### 4. Documentation

Provides a high-level description of the test suite. This text appears in the execution logs and reports.

```robot
*** Settings ***
Documentation    Suite for testing the user registration flow.
...              Covers email validation, duplicate prevention, and confirmation emails.
```

### 5. Metadata

Adds custom metadata key-value pairs to the suite. Visible in `report.html`.

```robot
*** Settings ***
Metadata    Version       1.2.0
Metadata    Author        QA Team
Metadata    Environment   staging
Metadata    Jira          PROJ-1234
```

### 6. Suite Setup / Suite Teardown

Runs a keyword **once** before (setup) or after (teardown) all tests in the file.

```robot
*** Settings ***
Suite Setup       Initialize Database Connection
Suite Teardown    Close Database Connection
```

Use `Run Keywords` to call multiple keywords in a single setup or teardown:

```robot
*** Settings ***
Suite Setup    Run Keywords
...    Start Application Server
...    AND    Clear Test Data
...    AND    Create Default User
```

### 7. Test Setup / Test Teardown

Runs a keyword **before/after every individual test case** in the file. Can be overridden at the test case level.

```robot
*** Settings ***
Test Setup       Open Browser    ${BASE_URL}    ${BROWSER}
Test Teardown    Close Browser
```

### 8. Tags (Robot Framework 6+)

In **Robot Framework 6**, `Force Tags` and `Default Tags` were replaced by a single `Test Tags` setting:

```robot
*** Settings ***
Test Tags    regression    browser:chrome
```

`Test Tags` applies the listed tags to every test case in the suite.

> [!NOTE]
> `Force Tags` and `Default Tags` still work in RF 6 but are deprecated. Migrate to `Test Tags` for new projects.

Legacy syntax (RF 4/5 — avoid in new projects):

```robot
*** Settings ***
Force Tags      regression
Default Tags    smoke
```

### 9. Test Template

Sets a default template keyword for all test cases in the file, enabling data-driven testing without repeating `[Template]` in each test.

```robot
*** Settings ***
Test Template    Verify Login Fails With

*** Variables ***
${URL}    https://example.com/login

*** Test Cases ***              USERNAME       PASSWORD
Invalid Username                bad_user       correct_pw
Invalid Password                admin          wrong_pw
Empty Username                  ${EMPTY}       secret
Empty Password                  admin          ${EMPTY}

*** Keywords ***
Verify Login Fails With
    [Arguments]    ${username}    ${password}
    Open Browser    ${URL}    chrome
    Input Text        id:username    ${username}
    Input Password    id:password    ${password}
    Click Button      id:login-btn
    Element Should Be Visible    css:.error-message
    [Teardown]    Close Browser
```

### 10. Test Timeout

Sets the maximum execution time for every test in the suite. Any test that exceeds this limit is marked as failed.

```robot
*** Settings ***
Test Timeout    2 minutes
```

## Complete Example

The following shows all major settings in a single file:

```robot
*** Settings ***
Documentation    End-to-end tests for the checkout flow.
...              Requires a running application at ${BASE_URL}.

Library          SeleniumLibrary    timeout=15    run_on_failure=Capture Page Screenshot
Library          Collections
Resource         ../resources/common.resource
Resource         ../resources/checkout_page.resource
Variables        ../data/config.py

Metadata         Version       2.0.0
Metadata         Author        QA Team
Metadata         Ticket        PROJ-999

Suite Setup      Open Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown   Close All Browsers

Test Setup       Navigate To Home Page
Test Teardown    Run Keyword If Test Failed    Log    Test failed: ${TEST NAME}

Test Tags        checkout    e2e
Test Timeout     3 minutes
```

---

> [!IMPORTANT]
> Always use at least **two spaces** between a setting name and its value. A single space causes a parse error or unexpected behavior.

---

*Next: [Test Suites and Cases](07_test_suites_and_cases.md)*
