@echo off
REM WlanPasswords GUI Launcher
REM Starts the WPF GUI application

setlocal enabledelayedexpansion

REM Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"

REM Check if running as Administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo This application requires Administrator privileges.
    echo Please run this batch file as Administrator.
    pause
    exit /b 1
)

REM Run the PowerShell GUI script
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%WlanPasswords-GUI.ps1"

exit /b %errorlevel%
