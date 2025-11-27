<#
.SYNOPSIS
    WlanPasswords - WLAN Password Extraction Tool
.DESCRIPTION
    A PowerShell script to extract and export all saved WLAN passwords from your Windows PC/Laptop.
    Similar to wifi-passview but built in PowerShell with a modern approach.
.AUTHOR
    iamrealguexoxo
.VERSION
    1.0.0
.LICENSE
    MIT License
#>

param(
    [switch]$Export,
    [switch]$Silent
)

# ============================================
# Configuration
# ============================================
$script:AppName = "WlanPasswords"
$script:AppVersion = "1.0.0"
$script:Author = "iamrealguexoxo"
$script:GitHub = "https://github.com/iamrealguexoxo/wlanpasswords"

# Get current directory
$script:RootPath = Get-Location

# ============================================
# Helper Functions
# ============================================

function Show-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "    " -NoNewline
    Write-Host "WiFi" -ForegroundColor Yellow -NoNewline
    Write-Host " WlanPasswords v$script:AppVersion" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  by $script:Author" -ForegroundColor Gray
    Write-Host "  $script:GitHub" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-BartAscii {
    $bart = @"
    
         |\/\/\/|
         |      |
         |      |
         | (o)(o)
         C      _)
          | ,___|
          |   /
         /____\
        /      \
    
    Ay caramba!
    
"@
    Write-Host $bart -ForegroundColor Yellow
}

function Get-WlanProfiles {
    <#
    .SYNOPSIS
        Get all saved WLAN profiles from the system
    #>
    try {
        $profiles = netsh wlan show profiles 2>&1
        if ($LASTEXITCODE -ne 0 -or $profiles -match "is not running") {
            return $null
        }
        
        $profileNames = @()
        foreach ($line in $profiles) {
            if ($line -match "All User Profile\s*:\s*(.+)$" -or $line -match "Profil f.+r alle Benutzer\s*:\s*(.+)$") {
                $profileNames += $matches[1].Trim()
            }
        }
        return $profileNames
    }
    catch {
        return $null
    }
}

function Get-WlanPassword {
    <#
    .SYNOPSIS
        Get the password for a specific WLAN profile
    .PARAMETER ProfileName
        The name of the WLAN profile
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$ProfileName
    )
    
    try {
        $profileInfo = netsh wlan show profile name="$ProfileName" key=clear 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            return $null
        }
        
        $password = $null
        foreach ($line in $profileInfo) {
            # English: Key Content
            # German: Schluesselinhalt
            if ($line -match "Key Content\s*:\s*(.+)$" -or $line -match "Schl.sselinhalt\s*:\s*(.+)$") {
                $password = $matches[1].Trim()
                break
            }
        }
        
        return $password
    }
    catch {
        return $null
    }
}

function Get-AllWlanCredentials {
    <#
    .SYNOPSIS
        Get all WLAN profiles with their passwords
    #>
    $profiles = Get-WlanProfiles
    
    if ($null -eq $profiles -or $profiles.Count -eq 0) {
        return $null
    }
    
    $credentials = @()
    foreach ($profile in $profiles) {
        $password = Get-WlanPassword -ProfileName $profile
        $credentials += [PSCustomObject]@{
            SSID = $profile
            Password = if ($password) { $password } else { "(No password / Open network)" }
        }
    }
    
    return $credentials
}

function Show-WlanCredentials {
    <#
    .SYNOPSIS
        Display all WLAN credentials in a formatted table
    #>
    Write-Host ""
    Write-Host "  Scanning for saved WLAN profiles..." -ForegroundColor Cyan
    Write-Host ""
    
    $credentials = Get-AllWlanCredentials
    
    if ($null -eq $credentials -or $credentials.Count -eq 0) {
        Write-Host "  No WLAN profiles found or WLAN service not available!" -ForegroundColor Red
        Write-Host ""
        return
    }
    
    Write-Host "  Found $($credentials.Count) WLAN profile(s):" -ForegroundColor Green
    Write-Host ""
    Write-Host "  ============================================" -ForegroundColor Cyan
    
    foreach ($cred in $credentials) {
        Write-Host ""
        Write-Host "  SSID: " -NoNewline -ForegroundColor White
        Write-Host "$($cred.SSID)" -ForegroundColor Yellow
        Write-Host "  Password: " -NoNewline -ForegroundColor White
        if ($cred.Password -eq "(No password / Open network)") {
            Write-Host "$($cred.Password)" -ForegroundColor DarkGray
        } else {
            Write-Host "$($cred.Password)" -ForegroundColor Green
        }
        Write-Host "  --------------------------------------------" -ForegroundColor DarkGray
    }
    
    Write-Host ""
}

function Export-WlanCredentials {
    <#
    .SYNOPSIS
        Export all WLAN credentials to a file
    .PARAMETER OutputPath
        Optional path for the output file
    #>
    param(
        [string]$OutputPath = $null
    )
    
    if ([string]::IsNullOrEmpty($OutputPath)) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $OutputPath = Join-Path $script:RootPath "wlan_passwords_$timestamp.txt"
    }
    
    Write-Host ""
    Write-Host "  Extracting WLAN credentials..." -ForegroundColor Cyan
    
    $credentials = Get-AllWlanCredentials
    
    if ($null -eq $credentials -or $credentials.Count -eq 0) {
        Write-Host "  No WLAN profiles found or WLAN service not available!" -ForegroundColor Red
        return $false
    }
    
    try {
        $content = @()
        $content += "============================================"
        $content += " WlanPasswords - WLAN Password Export"
        $content += " by $script:Author"
        $content += " Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $content += "============================================"
        $content += ""
        $content += "Total profiles found: $($credentials.Count)"
        $content += ""
        $content += "============================================"
        
        foreach ($cred in $credentials) {
            $content += ""
            $content += "SSID: $($cred.SSID)"
            $content += "Password: $($cred.Password)"
            $content += "--------------------------------------------"
        }
        
        $content += ""
        $content += "============================================"
        $content += " End of Export"
        $content += "============================================"
        
        $content | Out-File -FilePath $OutputPath -Encoding UTF8
        
        Write-Host ""
        Write-Host "  Credentials exported successfully!" -ForegroundColor Green
        Write-Host "  File: $OutputPath" -ForegroundColor Yellow
        Write-Host ""
        
        return $true
    }
    catch {
        Write-Host "  Error exporting credentials: $_" -ForegroundColor Red
        return $false
    }
}

function Show-SingleProfile {
    <#
    .SYNOPSIS
        Show details for a single WLAN profile
    #>
    Write-Host ""
    Write-Host "  Enter the SSID name (or 'back' to return):" -ForegroundColor White
    Write-Host ""
    $ssid = Read-Host "  SSID"
    
    if ($ssid -eq "back" -or [string]::IsNullOrEmpty($ssid)) {
        return
    }
    
    $password = Get-WlanPassword -ProfileName $ssid
    
    Write-Host ""
    Write-Host "  ============================================" -ForegroundColor Cyan
    Write-Host "  SSID: " -NoNewline -ForegroundColor White
    Write-Host "$ssid" -ForegroundColor Yellow
    Write-Host "  Password: " -NoNewline -ForegroundColor White
    
    if ($null -eq $password) {
        Write-Host "(Profile not found or no password)" -ForegroundColor Red
    }
    elseif ($password -eq "") {
        Write-Host "(Open network - no password)" -ForegroundColor DarkGray
    }
    else {
        Write-Host "$password" -ForegroundColor Green
    }
    Write-Host "  ============================================" -ForegroundColor Cyan
    Write-Host ""
}

function Show-About {
    <#
    .SYNOPSIS
        Show about information with Bart ASCII art
    #>
    Clear-Host
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "         About $script:AppName" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Show-BartAscii
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Name:    $script:AppName" -ForegroundColor White
    Write-Host "  Version: $script:AppVersion" -ForegroundColor White
    Write-Host "  Author:  $script:Author" -ForegroundColor White
    Write-Host "  GitHub:  $script:GitHub" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  This tool extracts saved WLAN passwords" -ForegroundColor Gray
    Write-Host "  from your Windows PC or Laptop." -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Inspired by:" -ForegroundColor Gray
    Write-Host "  - wifi-passview by warengonzaga" -ForegroundColor DarkGray
    Write-Host "  - BartsTOK & DeadMan by iamrealguexoxo" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  License: MIT" -ForegroundColor Gray
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Press any key to return to menu..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Show-MainMenu {
    <#
    .SYNOPSIS
        Display the main menu
    #>
    Show-Banner
    
    Write-Host "  [1] Show All WLAN Passwords" -ForegroundColor White
    Write-Host "  [2] Export All Passwords to File" -ForegroundColor White
    Write-Host "  [3] Search Single Network" -ForegroundColor White
    Write-Host "  [4] About" -ForegroundColor White
    Write-Host "  [5] Exit" -ForegroundColor White
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================
# Main Program
# ============================================

# Handle command line parameters
if ($Export) {
    if (-not $Silent) {
        Show-Banner
    }
    $result = Export-WlanCredentials
    if (-not $Silent) {
        Write-Host ""
        Write-Host "  Press any key to exit..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    exit $(if ($result) { 0 } else { 1 })
}

# Interactive menu mode
do {
    Show-MainMenu
    
    $choice = Read-Host "  Select option"
    
    switch ($choice) {
        "1" {
            Show-WlanCredentials
            Write-Host ""
            Write-Host "  Press any key to return to menu..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "2" {
            Export-WlanCredentials
            Write-Host ""
            Write-Host "  Press any key to return to menu..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "3" {
            Show-SingleProfile
            Write-Host ""
            Write-Host "  Press any key to return to menu..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        "4" {
            Show-About
        }
        "5" {
            Clear-Host
            Write-Host ""
            Write-Host "  Goodbye! Stay secure! " -ForegroundColor Cyan
            Write-Host ""
            exit 0
        }
        default {
            Write-Host ""
            Write-Host "  Invalid option! Please try again." -ForegroundColor Red
            Write-Host ""
            Write-Host "  Press any key to continue..." -ForegroundColor Yellow
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($true)
