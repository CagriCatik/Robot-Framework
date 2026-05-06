# Configuration & IDE Setup

After installing Robot Framework, proper environment configuration and a well-equipped IDE are essential for a smooth development workflow.

## Environment Variables (PATH)

If you did not select "Add Python to PATH" during installation, manually add the following directories to your system's Environment Variables:

1. **Python Installation Directory**: e.g., `C:\Python311`
2. **Scripts Directory**: e.g., `C:\Python311\Scripts`

Adding these ensures that commands like `python`, `pip`, and `robot` can be executed from any terminal window.

### Windows — Adding to PATH (GUI)

1. Search for **"Environment Variables"** in the Start menu.
2. Click **"Edit the system environment variables"**.
3. Under **System Variables**, find `Path` and click **Edit**.
4. Add each directory as a new entry.

### Windows — Adding to PATH (PowerShell, current user)

```powershell
$pythonPath = "C:\Python311"
$scriptsPath = "C:\Python311\Scripts"
[Environment]::SetEnvironmentVariable(
    "Path",
    "$env:Path;$pythonPath;$scriptsPath",
    "User"
)
```

## VS Code Setup

Visual Studio Code is highly recommended for Robot Framework development due to its lightweight nature and powerful extensions.

### 1. Recommended Extensions

Search for and install the following extensions from the VS Code Marketplace:

- **Robot Framework Language Server** (by Robocorp): Provides syntax highlighting, code completion, keyword documentation, and navigation.
- **Robot Framework Intellisense**: An alternative extension for syntax highlighting and basic intellisense.

### 2. Language Server Configuration

After installing the Robot Framework Language Server, add the following to your VS Code `settings.json` to point it at your virtual environment:

```json
{
  "robot.language-server.python": "${workspaceFolder}/.venv/Scripts/python.exe",
  "robot.python.executable": "${workspaceFolder}/.venv/Scripts/python.exe",
  "robot.pythonpath": ["${workspaceFolder}"]
}
```

> [!NOTE]
> On macOS/Linux, replace `Scripts/python.exe` with `bin/python`.

### 3. Key Editor Features

- **Syntax Highlighting**: Keywords, variables, and comments are color-coded automatically.
- **Go to Definition**: `Ctrl + Click` on a keyword to navigate to its definition in a resource file or library.
- **Keyword Completion**: The language server parses imported libraries and resource files and offers autocompletion.
- **Hover Documentation**: Hover over any keyword to see its documentation and signature.

## Static Analysis with Robocop

`robocop` is the official linter for Robot Framework files. It catches style violations, deprecated syntax, and common mistakes before execution.

```bash
pip install robotframework-robocop
robocop --include W0301 tests/
```

Run it on the entire project:

```bash
robocop .
```

## Auto-Formatting with Robotidy

`robotidy` automatically formats `.robot` and `.resource` files, enforcing consistent spacing and indentation.

```bash
pip install robotframework-tidy
robotidy .
```

Check formatting without applying changes:

```bash
robotidy --check .
```

## Recommended Project Structure

A well-organized project is easier to maintain. Here is a recommended folder structure for this project:

```text
MyRobotProject/
├── tests/                  # All .robot files (Test Suites)
│   ├── login_tests.robot
│   ├── checkout_tests.robot
│   └── api/
│       └── user_api_tests.robot
├── resources/              # Reusable keywords and variables (.resource files)
│   ├── common.resource
│   ├── login_page.resource
│   └── locators.resource
├── libraries/              # Custom Python keyword libraries
│   └── DateUtils.py
├── data/                   # External test data (CSV, JSON, YAML, Excel)
│   └── users.json
├── results/                # Execution artifacts (logs, reports — auto-created)
├── .venv/                  # Virtual environment (excluded from Git)
├── requirements-rf.txt     # Project library dependencies
├── .gitignore
└── README.md
```

### Why this structure?

- **tests/**: Keeps test logic separate from implementation details.
- **resources/**: Encourages code reuse and modularity.
- **libraries/**: Contains custom Python keyword libraries.
- **data/**: Separates test data from test logic.
- **results/**: Keeps the project root clean by grouping execution artifacts.

## .gitignore for Robot Framework Projects

Add the following to `.gitignore` to keep your repository clean:

```gitignore
# Virtual environment
.venv/
venv/
env/

# Robot Framework results
results/
output.xml
log.html
report.html

# Python cache
__pycache__/
*.py[cod]
*.pyo

# IDE files
.vscode/
.idea/
*.iml
```

## Running Tests from VS Code

With the Robot Framework Language Server installed, you can run tests directly from VS Code:

1. Open the **Testing** panel (beaker icon in the sidebar).
2. The extension discovers all `.robot` files automatically.
3. Click the run or debug button next to any test case.

Alternatively, use the integrated terminal:

```bash
robot -d results tests/
```

---

*Next: [Project Structure & File Anatomy](05_robot-project.md)*
