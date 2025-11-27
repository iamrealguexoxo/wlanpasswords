@echo off
title WlanPasswords - WLAN Password Extraction Tool
cd /d "%~dp0"

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
powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0WlanPasswords.ps1" %*
