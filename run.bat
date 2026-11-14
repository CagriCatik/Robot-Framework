@echo off
setlocal
echo ==========================================
echo   Robot Framework - Documentation Setup
echo ==========================================
echo.

:: Check for virtual environment
if not exist ".venv" (
    echo [1/3] Creating virtual environment...
    python -m venv .venv
)

:: Activate virtual environment
echo [2/3] Activating virtual environment...
call .venv\Scripts\activate

:: Install requirements
if exist "requirements-docs.txt" (
    echo [3/3] Installing/Updating documentation dependencies...
    pip install -q -r requirements-docs.txt
) else (
    echo [!] requirements-docs.txt not found. skipping installation.
)

echo.
echo ==========================================
echo   Starting Zensical server at http://127.0.0.1:8000
echo   Press Ctrl+C to stop the server.
echo ==========================================
echo.

:: Run zensical
zensical serve

if %ERRORLEVEL% neq 0 (
    echo.
    echo [!] Failed to start Zensical. Ensure you have Python installed and requirements-docs.txt is valid.
    pause
)

endlocal