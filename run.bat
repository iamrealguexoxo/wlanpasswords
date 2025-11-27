@echo off
title WlanPasswords - WLAN Password Extraction Tool
cd /d "%~dp0"

REM Check if PowerShell is available
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: PowerShell is not available on this system.
    echo Please install PowerShell to use this tool.
    pause
    exit /b 1
)

REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0WlanPasswords.ps1" %*
