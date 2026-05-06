# Resource Files

Resource files (`.resource`) are the key to building large-scale, maintainable automation projects. They allow you to centralize keywords and variables, making them available to multiple test suites.

## Why Use Resource Files?

Without resource files, you would copy and paste common keywords (like `Login`) into every `.robot` file. If the login logic changes, you must update every file.

With a resource file, you update the logic in **one place** and all suites that import it are updated automatically.

## Creating a Resource File

A resource file looks like a `.robot` file but **cannot contain a `*** Test Cases ***` section**.

```robot
# resources/common.resource

*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE_URL}      https://example.com
${BROWSER}       chrome

*** Keywords ***
Open App
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window

Close App
    Close All Browsers
```

## Importing a Resource File

Use the `Resource` setting in `*** Settings ***`.

```robot
# tests/login_tests.robot

*** Settings ***
Resource    ../resources/common.resource

*** Test Cases ***
Example Test
    Open App
    Title Should Be    Example Domain
    [Teardown]    Close App
```

### Portable Paths with `${CURDIR}`

To make imports work regardless of where `robot` is invoked, use `${CURDIR}`:

```robot
*** Settings ***
Resource    ${CURDIR}/../resources/common.resource
```

`${CURDIR}` always resolves to the directory of the file containing the statement.

## Organizing Large Projects with Multiple Resource Files

Split resource files by page or domain concept — this is the **Page Object Pattern** for Robot Framework:

```text
resources/
├── common.resource         # shared setup/teardown, browser helpers
├── login_page.resource     # locators and keywords for the login page
├── dashboard.resource      # locators and keywords for the dashboard
├── checkout.resource       # locators and keywords for checkout flow
└── api_helpers.resource    # RequestsLibrary session setup and shared API calls
```

### `common.resource` — Shared Lifecycle

```robot
# resources/common.resource

*** Settings ***
Library    SeleniumLibrary    timeout=15    run_on_failure=Capture Page Screenshot
Library    RequestsLibrary

*** Variables ***
${BASE_URL}      https://example.com
${BROWSER}       chrome
${API_URL}       https://api.example.com

*** Keywords ***
Open Browser To Base URL
    Open Browser    ${BASE_URL}    ${BROWSER}
    Maximize Browser Window

Close All Sessions
    Close All Browsers
    Delete All Sessions
```

### `login_page.resource` — Page-Specific Keywords

```robot
# resources/login_page.resource

*** Settings ***
Resource    common.resource

*** Variables ***
${USERNAME_INPUT}    id:username
${PASSWORD_INPUT}    id:password
${LOGIN_BUTTON}      id:login-btn
${ERROR_MESSAGE}     css:.error-message

*** Keywords ***
Navigate To Login Page
    Go To    ${BASE_URL}/login
    Title Should Be    Login

Login As
    [Arguments]    ${username}    ${password}
    Input Text        ${USERNAME_INPUT}    ${username}
    Input Password    ${PASSWORD_INPUT}    ${password}
    Click Button      ${LOGIN_BUTTON}

Login Error Should Be
    [Arguments]    ${expected_text}
    Element Should Be Visible    ${ERROR_MESSAGE}
    Element Text Should Be       ${ERROR_MESSAGE}    ${expected_text}
```

### Using Both in a Test Suite

```robot
# tests/login_tests.robot

*** Settings ***
Resource    ../resources/login_page.resource

Suite Setup       Open Browser To Base URL
Suite Teardown    Close All Sessions
Test Setup        Navigate To Login Page

*** Test Cases ***
Valid Login Redirects To Dashboard
    [Tags]    smoke    login
    Login As    admin    secret
    Location Should Contain    /dashboard

Invalid Password Shows Error
    [Tags]    login    negative
    Login As    admin    wrongpassword
    Login Error Should Be    Invalid username or password
```

## Variable Files

For large or environment-specific data, use Python or YAML variable files instead of hardcoding in resource files.

### Python Variable File

```python
# data/config.py
BASE_URL = "https://example.com"
BROWSER = "chrome"
TIMEOUT = 15
```

### YAML Variable File

```yaml
# data/environments.yaml
STAGING:
  BASE_URL: https://staging.example.com
  API_URL: https://staging-api.example.com

PRODUCTION:
  BASE_URL: https://example.com
  API_URL: https://api.example.com
```

Import in Settings:

```robot
*** Settings ***
Variables    ${CURDIR}/../data/config.py
```

Or pass at the command line to switch environments:

```bash
robot --variablefile data/staging_config.py tests/
robot --variablefile data/production_config.py tests/
```

## Visibility and Inheritance

- **Libraries**: Importing a library in a resource file makes that library's keywords available to any test suite that imports the resource.
- **Variables**: All variables declared in a resource file are available to the importing test suite and all other resource files it imports.
- **Keywords**: All keywords in the resource file are available to the importing test suite.
- **Transitive imports**: If `resource_a.resource` imports `resource_b.resource`, any test suite that imports `resource_a` also gains access to everything in `resource_b`.

> [!NOTE]
> In the execution `log.html`, Robot Framework shows which file each keyword came from (e.g., `login_page.Login As`). This makes it easy to trace the source of a failing keyword.

## Shared Setup and Teardown Resource

A common pattern is to centralize suite setup and teardown in a shared resource:

```robot
# resources/lifecycle.resource

*** Settings ***
Library    SeleniumLibrary
Library    RequestsLibrary

*** Keywords ***
Start Test Suite
    [Arguments]    ${url}=${BASE_URL}    ${browser}=${BROWSER}
    Open Browser    ${url}    ${browser}
    Maximize Browser Window
    Create Session    api    ${API_URL}

End Test Suite
    Close All Browsers
    Delete All Sessions
```

Use it across any suite:

```robot
*** Settings ***
Resource    ../resources/lifecycle.resource

Suite Setup       Start Test Suite
Suite Teardown    End Test Suite
```

---

*Next: [Best Practices](12_best_practices.md)*
