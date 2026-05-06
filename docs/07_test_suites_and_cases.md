# Test Suites and Cases

Robot Framework provides flexible ways to organize and execute tests, whether they are individual files or grouped into suites and folders.

## Defining a Test Case

Test cases are defined in the `*** Test Cases ***` section.

- **Name**: Must start at the beginning of the line (no leading spaces).
- **Body**: Consists of keyword calls indented with at least two spaces.

```robot
*** Test Cases ***
My First Test
    Log    This is a test case
```

## Test Case Settings

Each test case can have its own settings, written as bracketed entries before or within the keyword body.

| Setting | Purpose |
| ------- | ------- |
| `[Documentation]` | Describes what the test verifies |
| `[Tags]` | Categorizes the test for filtering and reporting |
| `[Setup]` | Keyword to run before this specific test |
| `[Teardown]` | Keyword to run after this specific test (even if failed) |
| `[Timeout]` | Maximum execution time for this test |
| `[Template]` | Sets a keyword as the test template for data-driven tests |

```robot
*** Test Cases ***
User Can Log In With Valid Credentials
    [Documentation]    Verifies successful login and redirect to dashboard.
    [Tags]             smoke    login    priority:high
    [Setup]            Navigate To Login Page
    [Teardown]         Close Browser
    [Timeout]          1 minute
    Input Text        id:username    admin
    Input Password    id:password    secret
    Click Button      id:login-btn
    Location Should Contain    /dashboard
```

## Test Suites vs. Test Cases

- **Test Case File**: A single `.robot` file containing multiple test cases. When executed, it behaves as a single suite.
- **Test Suite (Folder)**: A directory containing multiple `.robot` files. Robot Framework treats the entire directory as a nested test suite hierarchy.

## Tags

Tags are free-form labels attached to test cases. They serve several purposes:

- **Selective execution**: Run only tests with (or without) certain tags.
- **Reporting**: Filter results by tag in `report.html`.
- **Documentation**: Communicate intent (e.g., `smoke`, `regression`, `WIP`, `jira:PROJ-123`).

```robot
*** Test Cases ***
Add Item To Cart
    [Tags]    smoke    cart    positive
    ...

User Cannot Check Out With Empty Cart
    [Tags]    cart    negative    regression
    ...
```

## Organizing Your Project

### 1. Individual Test Files

Each functional area has its own `.robot` file.

```text
tests/
├── login_tests.robot
├── checkout_tests.robot
└── search_tests.robot
```

### 2. Grouped Test Suites (Folders)

Large projects group related tests into folders. Each subfolder is a nested suite.

```text
tests/
├── __init__.robot          # suite-level setup for all tests
├── ui/
│   ├── __init__.robot
│   ├── login_tests.robot
│   └── checkout_tests.robot
└── api/
    ├── __init__.robot
    └── user_api_tests.robot
```

## Data-Driven Test Cases with Templates

A **template** replaces the keyword body of a test case with a single keyword. Each test case then provides only the data (arguments). This pattern is ideal for testing the same behavior with many input/output combinations.

### `[Template]` per Test Case

```robot
*** Test Cases ***
Login With Bad Credentials
    [Template]    Login Should Fail With Message
    invalid_user    correct_pw    Invalid username or password
    admin           wrong_pw      Invalid username or password
    ${EMPTY}        ${EMPTY}      Username is required

*** Keywords ***
Login Should Fail With Message
    [Arguments]    ${username}    ${password}    ${expected_msg}
    Input Text        id:username    ${username}
    Input Password    id:password    ${password}
    Click Button      id:login-btn
    Element Text Should Be    css:.error-msg    ${expected_msg}
```

### Suite-Level `Test Template`

Set the template once in `*** Settings ***` and define only data rows in `*** Test Cases ***`:

```robot
*** Settings ***
Test Template    Validate Form Field

*** Test Cases ***           FIELD_ID      VALUE         EXPECTED_ERROR
Empty Email Field            email         ${EMPTY}      Email is required
Invalid Email Format         email         notanemail    Enter a valid email
Email Too Long               email         ${'a' * 300}  Email is too long

*** Keywords ***
Validate Form Field
    [Arguments]    ${field_id}    ${value}    ${expected_error}
    Input Text     id:${field_id}    ${value}
    Click Button   id:submit
    Element Text Should Be    css:.field-error    ${expected_error}
```

## Running Tests

### Running a Single File

```bash
robot tests/login_tests.robot
```

### Running Multiple Files

```bash
robot tests/login_tests.robot tests/checkout_tests.robot
```

### Running an Entire Folder

```bash
robot tests/
```

Robot Framework recursively finds and executes all `.robot` files in the folder.

### Selecting a Specific Suite

Use `--suite` (short: `-s`) to match suite names (case-insensitive, supports glob `*`):

```bash
robot --suite login_tests tests/
robot --suite "ui.*" tests/
```

### Selecting a Specific Test Case

Use `--test` (short: `-t`) to match test names:

```bash
robot --test "User Can Log In*" tests/
robot --test "Valid Login*" --test "Invalid Login*" tests/
```

### Filtering by Tag

```bash
# Run only smoke tests
robot --include smoke tests/

# Exclude work-in-progress tests
robot --exclude WIP tests/

# Run tests tagged smoke AND regression
robot --include smokeANDregression tests/

# Run tests tagged smoke OR regression
robot --include smokeORregression tests/
```

### Dry Run — Validate Without Executing

Check for syntax errors and missing keywords without running the tests:

```bash
robot --dryrun tests/
```

---

> [!TIP]
> Group test cases that share the same libraries and resource files into the same suite file to improve maintainability and reduce library initialization overhead.

---

*Next: [Execution and Logging](08_execution_and_logging.md)*
