@echo off
title WlanPasswords - WLAN Password Extraction Tool
cd /d "%~dp0"

REM ========== AUTO-ELEVATE TO ADMIN ==========
REM Check if already running as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

REM Check if PowerShell is available by checking common locations
if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
    goto :run_script
)
if exist "%SystemRoot%\SysWOW64\WindowsPowerShell\v1.0\powershell.exe" (
    goto :run_script
)

REM PowerShell not found
echo Error: PowerShell is not available on this system.
echo Please install PowerShell to use this tool.
pause
exit /b 1

:run_script
REM Run the PowerShell script
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0scripts\WlanPasswords.ps1" %*
