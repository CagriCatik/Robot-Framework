# Best Practices

To build a scalable and maintainable automation suite, follow these industry-standard best practices.

## 1. Modularization with Resource Files

Never put all your logic in a single file. Centralize reusable keywords and variables in `.resource` files. This ensures that a change in the application (like a URL update) only needs to be made in one place.

```text
resources/
├── common.resource         # lifecycle helpers (open/close browser, sessions)
├── login_page.resource     # login page locators and keywords
├── dashboard.resource      # dashboard locators and keywords
└── api_helpers.resource    # API session setup and shared request helpers
```

See [Resource Files](11_resource_files.md) for a full example.

## 2. Page Object Pattern (POM)

Organize resource files by page or functional module:

- `login_page.resource` — locators and keywords specific to the login page
- `dashboard.resource` — locators and keywords for the dashboard
- `checkout.resource` — locators and keywords for the checkout flow

Each page resource file declares its own locator variables in `*** Variables ***` and exposes business-level keywords in `*** Keywords ***`. Test cases import the page resource and call the keywords — they never touch locators directly.

```robot
# resources/checkout.resource

*** Variables ***
${CART_ICON}         css:.cart-icon
${CHECKOUT_BTN}      id:checkout-btn
${ORDER_CONFIRM}     css:.order-confirmation

*** Keywords ***
Proceed To Checkout
    Click Element    ${CART_ICON}
    Click Button     ${CHECKOUT_BTN}

Order Confirmation Should Be Visible
    Element Should Be Visible    ${ORDER_CONFIRM}
```

## 3. Clear Separation: "What" vs. "How"

Test cases should describe **business logic** (What). Keywords handle **technical implementation** (How).

```robot
# BAD — test case contains implementation details
*** Test Cases ***
Checkout Flow
    Click Element    css:.cart-icon
    Click Button     id:checkout-btn
    Wait Until Element Is Visible    css:.order-confirmation
    Element Text Should Be           css:.order-confirmation    Order placed!

# GOOD — test case reads as a business specification
*** Test Cases ***
Checkout Flow
    [Tags]    smoke    checkout
    Add Product To Cart    laptop
    Proceed To Checkout
    Complete Payment With    visa    4111111111111111
    Order Confirmation Should Be Visible
```

## 4. Descriptive Naming

- **Test Cases**: Readable sentences that describe what is being verified.
  - `Invalid login should show error message`
  - `User can add product to cart`
- **Keywords**: "Verb + Object" style.
  - `Login As`, `Click Logout Button`, `Verify Dashboard Is Visible`
- **Variables**: UPPER_CASE for suite/global scope; lower_case for local.
  - `${BASE_URL}`, `${BROWSER}`, local `${response}`, `${item_count}`
- **Files**: Use `snake_case` and descriptive names.
  - `login_tests.robot`, `checkout_page.resource`

## 5. Avoid Hardcoding

Use the `*** Variables ***` section or external variable files for environment-specific data:

```robot
# BAD
Open Browser    https://example.com    chrome

# GOOD
*** Variables ***
${BASE_URL}    https://example.com
${BROWSER}     chrome

Open Browser    ${BASE_URL}    ${BROWSER}
```

For multi-environment setups, use separate variable files and pass them at runtime:

```bash
robot --variablefile data/staging.py tests/
robot --variablefile data/production.py tests/
```

## 6. Proper Use of Setup and Teardown

- Use `Suite Setup` for one-time initializations (start server, open browser).
- Use `Suite Teardown` for cleanup that must happen once (stop server, close browser).
- Use `Test Teardown` for per-test cleanup — it runs **even if the test fails**, ensuring a clean state for the next test.

```robot
*** Settings ***
Suite Setup      Open Browser    ${BASE_URL}    ${BROWSER}
Suite Teardown   Close All Browsers
Test Teardown    Run Keywords
...    Run Keyword If Test Failed    Capture Page Screenshot
...    AND    Clear Cookies
```

## 7. Tagging for Strategy

Categorize your tests to enable selective execution:

| Tag | Usage |
| --- | ----- |
| `smoke` | Quick sanity check — runs on every commit |
| `regression` | Full suite — runs nightly or before a release |
| `critical` | Tests covering the most business-critical paths |
| `WIP` | Work in progress — excluded from CI |
| `slow` | Long-running tests — excluded from quick feedback loops |
| `jira:PROJ-123` | Links to a specific ticket |

```bash
# Run only smoke tests on every push
robot --include smoke tests/

# Run regression suite overnight
robot --include regression tests/

# Skip slow and WIP tests
robot --exclude slow --exclude WIP tests/
```

## 8. Data-Driven Testing

Use templates for scenarios with many input combinations:

```robot
*** Settings ***
Test Template    Registration Should Fail With

*** Test Cases ***            EMAIL              PASSWORD        EXPECTED_ERROR
Empty Email                   ${EMPTY}           valid_pw        Email is required
Invalid Email Format          notanemail         valid_pw        Enter a valid email
Short Password                user@ex.com        ab              Password too short
Mismatched Passwords          user@ex.com        valid_pw        Passwords do not match

*** Keywords ***
Registration Should Fail With
    [Arguments]    ${email}    ${password}    ${expected_error}
    Go To          ${BASE_URL}/register
    Input Text     id:email       ${email}
    Input Text     id:password    ${password}
    Click Button   id:register-btn
    Element Text Should Be    css:.form-error    ${expected_error}
```

## 9. Custom Python Libraries for Complex Logic

When keyword logic requires conditional branching, loops, or external integrations that are cumbersome to express in Robot syntax, implement it as a Python library:

```python
# libraries/ApiUtils.py
import requests

class ApiUtils:
    """Utility keywords for API testing."""

    def get_auth_token(self, base_url, username, password):
        """Authenticates and returns the JWT bearer token."""
        response = requests.post(
            f"{base_url}/auth/token",
            json={"username": username, "password": password},
            timeout=10,
        )
        response.raise_for_status()
        return response.json()["access_token"]

    def decode_jwt_payload(self, token):
        """Decodes a JWT payload without verifying the signature."""
        import base64, json
        payload = token.split(".")[1]
        # Add padding
        payload += "=" * (4 - len(payload) % 4)
        return json.loads(base64.b64decode(payload))
```

```robot
*** Settings ***
Library    ../libraries/ApiUtils.py

*** Test Cases ***
Admin Token Contains Admin Role
    ${token}=      Get Auth Token    ${API_URL}    admin    secret
    ${payload}=    Decode JWT Payload    ${token}
    Should Be Equal    ${payload}[role]    admin
```

## 10. Version Control

Always use Git. Exclude generated artifacts from the repository:

```gitignore
results/
output.xml
log.html
report.html
.venv/
__pycache__/
*.pyc
```

Commit meaningful messages when adding test cases:

```text
test(login): add negative test for locked account
test(checkout): add data-driven payment validation tests
fix(login_page): update locator for username input after UI redesign
```

## 11. CI/CD Integration

Run tests automatically on every push or pull request. See the [Execution and Logging](08_execution_and_logging.md#cicd-integration) page for complete GitHub Actions and GitLab CI examples.

Key CI practices:

- Always pass `--outputdir results` to keep artifacts in one place.
- Upload `results/` as a build artifact so log.html is accessible after the run.
- Use `--loglevel DEBUG` in CI for detailed failure diagnostics.
- Use `--variable BASE_URL:${{ env.STAGING_URL }}` to inject environment-specific values.

---

*Next: [Troubleshooting](13_troubleshooting.md)*
