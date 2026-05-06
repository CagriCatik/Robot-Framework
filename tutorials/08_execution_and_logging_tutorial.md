# Tutorial 08 — Execution Flags, Logging, and Debugging Failures

## The Scenario

A test failed in CI overnight. You have the `output.xml` artifact but no browser to reproduce the issue. A colleague changed a locator and now three tests are red. You need to find exactly which line broke and why — without running the full 40-test suite for every attempt.

This tutorial covers the execution flags that save time and the `log.html` anatomy that pinpoints failures.

## The Core Execution Pattern

Always use `-d results` so generated files stay out of the project root:

```powershell
robot -d results tests/
```

These three flags you will use every day:

```powershell
# Run only tests tagged smoke
robot -d results -i smoke tests/

# Run only the climate feature area
robot -d results --suite climate tests/

# Run only one specific test by name (glob patterns work)
robot -d results -t "Temperature Cannot Exceed*" tests/climate/
```

## Part 1 — Reading log.html Like a Professional

Run the climate suite and deliberately break one test. In `tests/climate/temperature_tests.robot`, change:

```robot
Element Text Should Be    id:climate-temperature-value    30°C
```

to:

```robot
Element Text Should Be    id:climate-temperature-value    31°C
```

Run:

```powershell
robot -d results tests/climate/temperature_tests.robot
```

Open `results/log.html`. Here is what to look for:

1. **Red suite bar at the top** — click to jump to the first failure
2. **Expand the failing test** — all keywords before the failure are green
3. **Find the red keyword** — `Element Text Should Be` is red
4. **Read the error message**: `Actual value 'cli 30°C' does not match expected 'cli 31°C'`
5. **Note the arguments** — you see exactly what was passed and what came back

The log tells you: "I looked at `id:climate-temperature-value`, it said `30°C`, you told me to expect `31°C`." The fix is immediately obvious.

Revert the change before moving on.

## Part 2 — Log Levels

By default, `Log` keywords write at `INFO` level and SeleniumLibrary keyword calls appear as a single line. Add `--loglevel DEBUG` to see every library call:

```powershell
robot -d results --loglevel DEBUG tests/climate/temperature_tests.robot
```

The log now shows internal SeleniumLibrary operations — every `find_element`, every `execute_script`. Useful when a selector is wrong but the error is cryptic.

`TRACE` level goes even further — it logs every argument going into and every return value coming out of every keyword:

```powershell
robot -d results --loglevel TRACE tests/climate/temperature_tests.robot
```

Use TRACE sparingly. On a 10-test suite it produces a 10 MB log file and slows down the run noticeably.

**Recommended levels by situation:**

| Situation | Level |
| --- | --- |
| Normal CI run | `INFO` (default) |
| Investigating a flaky test | `DEBUG` |
| Debugging a completely silent failure | `TRACE` |
| Viewing a quick summary | `WARN` |

## Part 3 — Override Variables at the Command Line

Your `resources/common.resource` has:

```robot
${SIMULATOR_URL}    file:///${EXECDIR}/simulator/index.html
${BROWSER}          chrome
```

To run the same tests against a hosted staging URL without changing any file:

```powershell
robot -d results -v SIMULATOR_URL:http://staging.internal/sim -v BROWSER:firefox tests/
```

Command-line variables always override `*** Variables ***` section values and variable files. This is how you switch environments without touching test code.

## Part 4 — Dry Run Before Every Significant Change

Before running a refactored suite:

```powershell
robot --dryrun tests/
```

Dry run catches:

- Missing keyword references (typos, renamed keywords)
- Bad library or resource imports
- Wrong number of arguments to a keyword
- Malformed section headers

It does **not** catch locator errors, timing issues, or wrong expected values — those only appear at runtime. But it filters out 80% of syntax problems in under a second.

Make dry run your first step after any rename or reorganisation.

## Part 5 — Combining Multiple Result Files with `rebot`

You ran climate tests and media tests in parallel (on different CI agents). Each produced its own `output.xml`. Merge them into one report:

```powershell
# Merge two separate runs
rebot -d results/merged results/climate/output.xml results/media/output.xml

# Open
start results/merged/report.html
```

`rebot` regenerates HTML from existing XML — it does not re-run any tests. You can also use it to filter an existing result:

```powershell
# Re-generate report showing only failed tests
rebot -d results/failures-only --include FAIL results/output.xml
```

## Part 6 — A Real Debugging Session

Your colleague updated the media source tabs and now the `Source Tab Becomes Active On Click` test fails silently — no exception, but the assertion is wrong. Here is the investigative sequence:

**Step 1** — Run with DEBUG to see what SeleniumLibrary is actually checking:

```powershell
robot -d results --loglevel DEBUG -t "Source Tab Becomes Active On Click" tests/media/
```

**Step 2** — In `log.html`, find the `Element Should Be Visible` call. Expand it. You see the CSS selector it used: `css:#media-source-bluetooth.active`. The `.active` class is there in the HTML but the element is still not found as visible.

**Step 3** — Inspect the selector. The issue: the selector `#media-source-bluetooth.active` expects both the ID and the class on the same element simultaneously. If the class is applied asynchronously, the assertion fires before the class is added.

**Step 4** — Replace the instant assertion with an explicit wait:

```robot
# Before (fragile)
Element Should Be Visible    css:#media-source-bluetooth.active

# After (waits up to 3 seconds for the class to appear)
Wait Until Element Contains    id:media-source-bluetooth    active    timeout=3s
```

Or check the `data-state` attribute instead, which is synchronously updated by the JavaScript:

```robot
Wait Until Element Is Visible    id:screen-media    timeout=3s
${class}=    Get Element Attribute    id:media-source-bluetooth    class
Should Contain    ${class}    active
```

**Step 5** — Run again and confirm the fix. Run with `INFO` level (default) to confirm the log stays clean.

## Part 7 — The CI Command

The command that CI should run:

```powershell
robot \
    --outputdir results \
    --loglevel DEBUG \
    --exclude WIP \
    --exclude slow \
    tests/
```

Always upload `results/` as an artifact even when tests fail — that is when the log matters most.

## Practice Challenge

1. Introduce a deliberate bug: in `tests/climate/temperature_tests.robot`, change the expected temperature boundary from `30°C` to `29°C`.
2. Run with `--loglevel INFO`. Note the error in `log.html`.
3. Run again with `--loglevel DEBUG`. What additional information appears?
4. Fix the bug, run dry run, then run normally and confirm green.
5. Run only the boundary tests using the `boundary` tag and confirm the count matches what you expect.
