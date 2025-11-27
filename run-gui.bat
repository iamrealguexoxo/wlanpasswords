@echo off
REM WlanPasswords GUI Launcher
REM Starts the WPF GUI application

setlocal enabledelayedexpansion

REM Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"

REM ========== AUTO-ELEVATE TO ADMIN ==========
REM Check if already running as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

REM Run the PowerShell GUI script
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%scripts\WlanPasswords-GUI.ps1"

exit /b %errorlevel%
