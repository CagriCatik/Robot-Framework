# Variables Deep Dive

Variables are essential for creating flexible, maintainable tests. They allow you to avoid hardcoding values like URLs, credentials, and web locators.

## Variable Types

### 1. Scalar Variables (`${scalar}`)

Used for a single value — a string, number, object, or return value from a keyword.

- **Declaration**: `${MY_VAR}    value`
- **Usage**: `${MY_VAR}`

```robot
*** Variables ***
${BASE_URL}     https://example.com
${BROWSER}      chrome
${TIMEOUT}      10

*** Test Cases ***
Use Scalar Variable
    Open Browser    ${BASE_URL}    ${BROWSER}
    Set Browser Implicit Wait    ${TIMEOUT}
```

### 2. List Variables (`@{list}`)

Used for ordered collections of values. Declaration uses `@{}` syntax, but **individual items are always accessed with `${}`**.

- **Declaration**: `@{MY_LIST}    item1    item2    item3`
- **Accessing Items**: `${MY_LIST}[0]` returns `item1` (0-indexed).
- **Iterating**: Use in a `FOR` loop with `@{MY_LIST}`.

```robot
*** Variables ***
@{BROWSERS}    chrome    firefox    edge

*** Test Cases ***
Test In Multiple Browsers
    FOR    ${browser}    IN    @{BROWSERS}
        Open Browser    https://example.com    ${browser}
        Title Should Be    Example Domain
        Close Browser
    END
```

> [!WARNING]
> In older versions of Robot Framework, list items were accessed with `@{list}[index]`. This syntax is deprecated. Always use `${list}[index]` for individual items.

### 3. Dictionary Variables (`&{dict}`)

Used for key-value pairs. Declaration uses `&{}` syntax; individual values are accessed with `${}`.

- **Declaration**: `&{USER}    username=admin    password=secret`
- **Accessing Items**: `${USER}[username]` returns `admin`.

```robot
*** Variables ***
&{ADMIN}     username=admin      password=secret
&{VIEWER}    username=viewer     password=readonly

*** Test Cases ***
Login As Admin
    Input Text        id:username    ${ADMIN}[username]
    Input Password    id:password    ${ADMIN}[password]
    Click Button      id:login-btn
```

## Built-In Variables

Robot Framework provides built-in variables automatically. You do not need to declare them.

| Variable | Value / Type | Description |
| -------- | ------------ | ----------- |
| `${EMPTY}` | `""` | An empty string |
| `${SPACE}` | `" "` | A single space character |
| `${TRUE}` | `True` (bool) | Boolean true |
| `${FALSE}` | `False` (bool) | Boolean false |
| `${None}` | `None` | Python None |
| `${CURDIR}` | Path string | Directory of the current file |
| `${EXECDIR}` | Path string | Directory where `robot` was invoked |
| `${TEMPDIR}` | Path string | System temporary directory |
| `${TEST NAME}` | String | Name of the currently running test |
| `${SUITE NAME}` | String | Name of the current suite |
| `${TEST STATUS}` | `PASS` or `FAIL` | Status of the current test (in teardown) |
| `${OUTPUT DIR}` | Path string | Directory where results are written |

```robot
*** Test Cases ***
Built-In Variables Example
    Should Be Equal    ${EMPTY}    ${EMPTY}
    Should Be True     ${TRUE}
    Log    Running test: ${TEST NAME} in suite: ${SUITE NAME}
    Log    Results go to: ${OUTPUT DIR}
```

## Environment Variables

Access OS environment variables using `%{VAR_NAME}`:

```robot
*** Variables ***
${DB_PASSWORD}    %{DB_PASSWORD}

*** Test Cases ***
Use Environment Variable
    Log    DB password length: ${DB_PASSWORD.__len__()}
```

If the environment variable is not set, Robot Framework raises an error. Provide a default fallback:

```bash
robot --variable DB_PASSWORD:fallback_value tests/
```

## Variable Scope

Variables in Robot Framework have four scopes:

| Scope | Set With (Legacy) | Set With (RF 7.0+) | Visible To |
| ----- | -------- | -------- | ---------- |
| **Local** | `${x}=    keyword` | `VAR    ${x}    value` | Current keyword only |
| **Test** | `Set Test Variable` | `VAR    ${x}    value    scope=TEST` | All keywords in the current test |
| **Suite** | `Set Suite Variable` | `VAR    ${x}    value    scope=SUITE` | All tests and keywords in the current suite |
| **Global** | `Set Global Variable` | `VAR    ${x}    value    scope=GLOBAL` | All tests and suites in the run |

> [!TIP]
> **New in Robot Framework 7.0:** The native `VAR` syntax is now the recommended way to create variables dynamically, replacing the older `Set Variable` and `Set * Variable` keywords. It is more concise and clearly defines the scope.

```robot
*** Keywords ***
Set Up Shared State
    # Legacy approach:
    Set Test Variable    ${SESSION_ID}    abc-123
    
    # Modern RF 7.0+ approach:
    VAR    ${SESSION_ID}    abc-123    scope=TEST
    VAR    ${APP_BASE_URL}  https://staging.example.com    scope=SUITE
    VAR    ${ENV}           staging    scope=GLOBAL
```

## Dynamic Variables

Use the `VAR` syntax to assign a value to a variable at runtime:

```robot
*** Test Cases ***
Dynamic Variable Example
    ${today}=    Get Current Date    result_format=%Y-%m-%d
    Log    Today's date is ${today}

    VAR    ${count}    0
    ${count}=    Evaluate    ${count} + 1
    Should Be Equal As Integers    ${count}    1
```


## Using `Evaluate` for Expressions

`Evaluate` runs a Python expression and returns the result. It has access to standard Python modules:

```robot
*** Test Cases ***
Evaluate Examples
    ${pi}=       Evaluate    math.pi    modules=math
    ${upper}=    Evaluate    "hello".upper()
    ${items}=    Evaluate    [i * 2 for i in range(5)]
    Log    ${items}    # [0, 2, 4, 6, 8]
```

## Variable Files

For large or environment-specific configurations, store variables in external Python or YAML files.

### Python Variable File

```python
# data/config.py
BASE_URL = "https://example.com"
BROWSER = "chrome"
TIMEOUT = 15

# Complex variables work too
ADMIN_USER = {"username": "admin", "password": "secret"}
```

### YAML Variable File

```yaml
# data/users.yaml
ADMIN_USER:
  username: admin
  password: secret

READONLY_USER:
  username: viewer
  password: view_only
```

Import in `*** Settings ***`:

```robot
*** Settings ***
Variables    ../data/config.py
Variables    ../data/users.yaml
```

Or pass at the command line:

```bash
robot --variablefile data/staging_config.py tests/
```

## Overriding Variables at the Command Line

Variables can be overridden when running tests without modifying any file:

```bash
robot --variable BASE_URL:https://staging.example.com tests/
robot --variable BROWSER:firefox --variable TIMEOUT:30 tests/
```

Command-line `--variable` values take precedence over `*** Variables ***` section values and variable files.

## Best Practices for Variables

### 1. Centralize Web Locators

Store locators in variables so they only need updating in one place:

```robot
*** Variables ***
${USERNAME_INPUT}     id:username
${PASSWORD_INPUT}     id:password
${LOGIN_BUTTON}       id:login-btn
${ERROR_MESSAGE}      css:.error-message
```

### 2. Naming Conventions

Use descriptive, `UPPER_CASE` names for global and suite-level variables:

- `${BASE_URL}`, `${BROWSER}`, `${ADMIN_USER}`

Use `lower_case` or `camelCase` for local variables inside keywords:

- `${response}`, `${currentUser}`, `${item_count}`

### 3. Avoid Hardcoding Sensitive Data

Never hardcode passwords or API keys in `.robot` files. Use environment variables or an external secrets manager:

```robot
*** Variables ***
${API_KEY}    %{API_KEY}
```

---

> [!NOTE]
> The **2-space rule** is critical here too. Always use at least two spaces between the variable name and its value in the `*** Variables ***` section.

---

*Next: [User-Defined Keywords](10_user_keywords.md)*
