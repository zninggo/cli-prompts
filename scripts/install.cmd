@echo off
setlocal

set "SCRIPT_DIR=%~dp0"

where pwsh >nul 2>nul
if %ERRORLEVEL%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1" %*
    exit /b %ERRORLEVEL%
)

where powershell >nul 2>nul
if %ERRORLEVEL%==0 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1" %*
    exit /b %ERRORLEVEL%
)

echo PowerShell not found. Please install PowerShell or run scripts\install.ps1 from PowerShell.
exit /b 1
