# Robot Framework Tutorial Example Project

This is a runnable companion project for the tutorials in the parent folder. It
implements every covered documentation section as a realistic automation example
against the repository's browser-based automotive infotainment simulator.

## Section Mapping

| Docs section | Runnable implementation |
| --- | --- |
| 01 Overview | `tests/01_overview.robot` |
| 02 About Robot Framework | `tests/02_about.robot` |
| 03 Installation | `tests/03_installation_check.robot` |
| 04 Configuration and IDE Setup | `tests/04_configuration.robot` |
| 05 Project Structure and File Anatomy | `tests/05_project_anatomy.robot` |
| 06 Settings Section | `tests/06_settings_section.robot` |
| 07 Test Suites and Cases | `tests/07_test_suites_and_cases.robot`, `tests/suites/` |
| 08 Execution and Logging | `tests/08_execution_and_logging.robot` |
| 09 Variables Deep Dive | `tests/09_variables_deep_dive.robot` |
| 10 User-Defined Keywords | `tests/10_user_keywords.robot` |
| 11 Resource Files | `tests/11_resource_files.robot` |
| 12 Best Practices | `tests/12_best_practices.robot` |
| 13 Troubleshooting | `tests/13_troubleshooting.robot` |

## Project Layout

```text
example_project/
|-- data/                  Python variable files
|-- libraries/             Custom Python keyword libraries
|-- resources/             Shared and page-object Robot Framework resources
|-- results/               Execution output directory
|-- tests/                 Executable tutorial suites
|-- run_all.bat            Runs every suite
|-- run_smoke.bat          Runs smoke-tagged examples
|-- requirements.txt       Points to the repository Robot requirements
```

## Run The Project

From the repository root:

```powershell
.\.venv\Scripts\robot.exe -d tutorials\example_project\results tutorials\example_project\tests
```

Or from this folder:

```powershell
run_all.bat
```

Run only smoke examples:

```powershell
run_smoke.bat
```

Run one section:

```powershell
..\..\.venv\Scripts\robot.exe -d results tests\09_variables_deep_dive.robot
```

## Learning Notes

- Most suites drive the real simulator UI with SeleniumLibrary.
- By default the browser runs headless. Set `TUTORIAL_HEADLESS=false` to watch it:

```powershell
$env:TUTORIAL_HEADLESS = "false"
run_all.bat
```

- API behavior is represented as a local contract helper so the tutorials do not
  depend on an external service.
- Generated reports and screenshots are written under `results/`.
