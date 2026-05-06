@echo off
setlocal
cd /d %~dp0

:: Check if venv is available in parent
if exist "..\.venv" (
    call "..\.venv\Scripts\activate"
)

echo.
echo ==========================================
echo   Running Robot Framework Tests...
echo ==========================================
echo.

:: Run all tests in the tests folder and store results in results/
robot -d results tests\

if %ERRORLEVEL% neq 0 (
    echo.
    echo [!] Some tests failed. Check results/log.html for details.
) else (
    echo.
    echo [x] All tests passed!
)

pause
endlocal
