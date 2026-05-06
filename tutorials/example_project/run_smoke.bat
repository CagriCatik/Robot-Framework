@echo off
setlocal
cd /d %~dp0

if exist "..\..\.venv\Scripts\activate.bat" (
    call "..\..\.venv\Scripts\activate.bat"
)

robot -d results -i smoke tests
exit /b %ERRORLEVEL%

