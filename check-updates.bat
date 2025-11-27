@echo off
REM WlanPasswords - Update Checker Launcher
REM This batch file runs the PowerShell update checker script

setlocal enabledelayedexpansion

REM Get the directory of this batch file
set "SCRIPT_DIR=%~dp0"

REM Run the PowerShell script
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%setup\check-updates.ps1"

exit /b %errorlevel%
