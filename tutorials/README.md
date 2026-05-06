# Robot Framework Tutorials

This folder contains hands-on tutorials that expand the documentation in `docs/`.
Each tutorial follows the same sequence as the numbered documentation pages and is
designed for learners who want to practice, not only read.

## Recommended Learning Path

Before or after reading the written tutorials, you can run the complete companion
project in [example_project](example_project/README.md). It implements every
covered section as executable Robot Framework suites.

1. [Robot Framework Overview Tutorial](01_overview_tutorial.md)
2. [About Robot Framework Tutorial](02_about_tutorial.md)
3. [Installation Tutorial](03_installation_tutorial.md)
4. [Configuration and IDE Setup Tutorial](04_configuration_tutorial.md)
5. [Project Structure and File Anatomy Tutorial](05_robot_project_tutorial.md)
6. [Settings Section Tutorial](06_settings_section_tutorial.md)
7. [Test Suites and Cases Tutorial](07_test_suites_and_cases_tutorial.md)
8. [Execution and Logging Tutorial](08_execution_and_logging_tutorial.md)
9. [Variables Deep Dive Tutorial](09_variables_deep_dive_tutorial.md)
10. [User-Defined Keywords Tutorial](10_user_keywords_tutorial.md)
11. [Resource Files Tutorial](11_resource_files_tutorial.md)
12. [Best Practices Tutorial](12_best_practices_tutorial.md)
13. [Troubleshooting Tutorial](13_troubleshooting_tutorial.md)

## How To Use These Tutorials

Start from tutorial 01 if you are new to Robot Framework. If you already have
Robot Framework installed, you can jump to tutorial 05 and begin writing tests.

Most exercises use a temporary folder named `learning-lab/`. Create it at the
repository root when you start practicing:

```powershell
mkdir learning-lab
cd learning-lab
```

For exercises that interact with the existing sample project, use the repository
root as your working directory:

```powershell
cd C:\Users\mccat\Desktop\Robot-Framework
```

## Assumptions

- You are using Windows PowerShell unless a command says otherwise.
- Python and pip are available as `python` and `pip`.
- Robot Framework commands are run from an activated virtual environment when possible.
- The sample application lives in `simulator/`.
- The runnable Robot Framework sample project lives in `project/`.

## Practice Rules

- Type the examples instead of copy-pasting when learning syntax.
- Always run `robot --dryrun` before a full execution while you are learning.
- Always write results to a dedicated output directory with `-d results`.
- Open `log.html` after failures. It is the most useful learning artifact.
