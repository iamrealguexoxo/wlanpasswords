<#
.SYNOPSIS
    WlanPasswords - WPF GUI
.DESCRIPTION
    Modern WPF GUI for WlanPasswords - Extract and view saved WLAN passwords
.AUTHOR
    iamrealguexoxo
.VERSION
    1.1.0
#>

# Add required assemblies
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# ============================================
# Configuration
# ============================================
$script:AppName = "WlanPasswords"
$script:AppVersion = "1.1.0"
$script:GitHub = "https://github.com/iamrealguexoxo/wlanpasswords"
$script:credentials = @()

# ============================================
# Helper Functions
# ============================================

function Get-WlanProfiles {
    try {
        $profiles = netsh wlan show profiles 2>&1
        if ($LASTEXITCODE -ne 0 -or $profiles -match "is not running") {
            return $null
        }
        
        $profileNames = @()
        foreach ($line in $profiles) {
            if ($line -match "All User Profile\s*:\s*(.+)$" -or $line -match "Profil für alle Benutzer\s*:\s*(.+)$") {
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
            if ($line -match "Key Content\s*:\s*(.+)$" -or $line -match "Schlüsselinhalt\s*:\s*(.+)$") {
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
            PasswordHidden = if ($password) { "••••••••" } else { "(No password)" }
        }
    }
    
    return $credentials
}

function Check-Version {
    try {
        $apiUrl = "https://api.github.com/repos/iamrealguexoxo/wlanpasswords/releases/latest"
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction Stop
        
        if ($null -eq $response.tag_name -or [string]::IsNullOrWhiteSpace($response.tag_name)) {
            return $null
        }
        
        $latestVersion = $response.tag_name -replace 'v', ''
        
        try {
            $localVer = [version]$script:AppVersion
            $remoteVer = [version]$latestVersion
            
            if ($remoteVer -gt $localVer) {
                return @{
                    UpdateAvailable = $true
                    LocalVersion = $script:AppVersion
                    RemoteVersion = $latestVersion
                    ReleaseUrl = $response.html_url
                }
            }
        } catch {
            return $null
        }
        
        return $null
    } catch {
        return $null
    }
}

function Show-MessageBox {
    param(
        [string]$Title,
        [string]$Message,
        [System.Windows.MessageBoxButton]$Button = [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]$Icon = [System.Windows.MessageBoxImage]::Information
    )
    
    [System.Windows.MessageBox]::Show($Message, $Title, $Button, $Icon)
}

# ============================================
# XAML UI Definition
# ============================================

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WlanPasswords v1.1.0" 
        Height="650" 
        Width="950"
        MinHeight="500"
        MinWidth="700"
        WindowStartupLocation="CenterScreen"
        Background="#1a1a2e">
    <Window.Resources>
        <Style x:Key="ModernButton" TargetType="Button">
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="FontSize" Value="12"/>
            <Setter Property="Padding" Value="15,8"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="BorderThickness" Value="0"/>
        </Style>
    </Window.Resources>
    
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="80"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="40"/>
        </Grid.RowDefinitions>
        
        <!-- Header -->
        <Border Grid.Row="0" Background="#16213e">
            <Grid Margin="25,0">
                <StackPanel VerticalAlignment="Center">
                    <TextBlock Text="WlanPasswords" FontSize="26" FontWeight="Bold" Foreground="#e94560" />
                    <TextBlock Text="Extract and manage your saved WiFi passwords" FontSize="11" Foreground="#8b8b8b" Margin="0,3,0,0"/>
                </StackPanel>
                
                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center">
                    <Button Name="RefreshButton" Width="44" Height="44" Margin="0,0,12,0" 
                            Background="#e94560" Foreground="White" FontSize="18" FontWeight="Bold"
                            ToolTip="Refresh" Content="R" Style="{StaticResource ModernButton}"/>
                    <Button Name="AboutButton" Width="44" Height="44" 
                            Background="#0f3460" Foreground="White" FontSize="18" FontWeight="Bold"
                            ToolTip="About" Content="?" Style="{StaticResource ModernButton}"/>
                </StackPanel>
            </Grid>
        </Border>
        
        <!-- Main Content -->
        <Grid Grid.Row="1" Margin="25,20,25,20">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="220"/>
            </Grid.ColumnDefinitions>
            
            <!-- Left Panel -->
            <Border Grid.Column="0" Background="#16213e" CornerRadius="8" Padding="20">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    
                    <!-- Search Bar - Now Full Width -->
                    <Border Grid.Row="0" Background="#0f3460" CornerRadius="6" Margin="0,0,0,15" Padding="5">
                        <Grid>
                            <Grid.ColumnDefinitions>
                                <ColumnDefinition Width="Auto"/>
                                <ColumnDefinition Width="*"/>
                            </Grid.ColumnDefinitions>
                            <TextBlock Grid.Column="0" Text="Search:" VerticalAlignment="Center" Margin="10,0,15,0" 
                                      FontWeight="SemiBold" Foreground="#e94560" FontSize="13"/>
                            <TextBox Name="SearchBox" Grid.Column="1" Height="35" Padding="12,8" 
                                    Background="#1a1a2e" Foreground="White" FontSize="13"
                                    BorderThickness="0" VerticalContentAlignment="Center"
                                    ToolTip="Type to filter networks by SSID..."/>
                        </Grid>
                    </Border>
                    
                    <!-- DataGrid -->
                    <DataGrid Grid.Row="1" Name="CredentialsGrid" 
                             AutoGenerateColumns="False" 
                             CanUserAddRows="False"
                             CanUserDeleteRows="False"
                             IsReadOnly="True"
                             GridLinesVisibility="Horizontal"
                             Background="#16213e"
                             Foreground="White"
                             BorderThickness="0"
                             RowBackground="#1a1a2e"
                             AlternatingRowBackground="#16213e"
                             HeadersVisibility="Column"
                             FontSize="13">
                        <DataGrid.ColumnHeaderStyle>
                            <Style TargetType="DataGridColumnHeader">
                                <Setter Property="Background" Value="#0f3460"/>
                                <Setter Property="Foreground" Value="#e94560"/>
                                <Setter Property="FontWeight" Value="Bold"/>
                                <Setter Property="FontSize" Value="13"/>
                                <Setter Property="Padding" Value="12,10"/>
                                <Setter Property="BorderThickness" Value="0"/>
                            </Style>
                        </DataGrid.ColumnHeaderStyle>
                        <DataGrid.CellStyle>
                            <Style TargetType="DataGridCell">
                                <Setter Property="Padding" Value="12,8"/>
                                <Setter Property="BorderThickness" Value="0"/>
                                <Setter Property="Foreground" Value="#cccccc"/>
                            </Style>
                        </DataGrid.CellStyle>
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="SSID (Network Name)" Binding="{Binding SSID}" Width="*" />
                            <DataGridTextColumn Header="Password" Binding="{Binding PasswordHidden}" Width="180" />
                        </DataGrid.Columns>
                    </DataGrid>
                </Grid>
            </Border>
            
            <!-- Right Panel - Actions -->
            <Border Grid.Column="1" Background="#16213e" CornerRadius="8" Margin="20,0,0,0" Padding="18">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    
                    <TextBlock Grid.Row="0" Text="ACTIONS" FontSize="11" FontWeight="Bold" Margin="0,0,0,18" 
                              Foreground="#e94560"/>
                    
                    <Button Grid.Row="1" Name="ShowPasswordButton" Height="42" Margin="0,0,0,12"
                            Background="#e94560" Foreground="White" 
                            ToolTip="Show selected password" Content="Show Password" Style="{StaticResource ModernButton}"/>
                    
                    <Button Grid.Row="2" Name="CopyPasswordButton" Height="42" Margin="0,0,0,12"
                            Background="#f39c12" Foreground="White"
                            ToolTip="Copy password to clipboard" Content="Copy to Clipboard" Style="{StaticResource ModernButton}"/>
                    
                    <Button Grid.Row="3" Name="ExportButton" Height="42" Margin="0,0,0,12"
                            Background="#0f3460" Foreground="White"
                            ToolTip="Export all passwords to file" Content="Export All" Style="{StaticResource ModernButton}"/>
                    
                    <Button Grid.Row="4" Name="RefreshManualButton" Height="42"
                            Background="#27ae60" Foreground="White"
                            ToolTip="Reload WLAN passwords" Content="Reload Networks" Style="{StaticResource ModernButton}"/>
                    
                    <!-- Stats -->
                    <Border Grid.Row="6" Background="#0f3460" CornerRadius="6" Padding="15" VerticalAlignment="Bottom">
                        <StackPanel>
                            <TextBlock Text="STATUS" FontSize="10" FontWeight="Bold" Foreground="#e94560" Margin="0,0,0,8"/>
                            <TextBlock Name="StatusText" Text="Ready" FontSize="11" Foreground="#27ae60" TextWrapping="Wrap"/>
                            
                            <Border Height="1" Background="#1a1a2e" Margin="0,12"/>
                            
                            <TextBlock Text="NETWORKS FOUND" FontSize="10" FontWeight="Bold" Foreground="#e94560" Margin="0,0,0,5"/>
                            <TextBlock Name="CountText" Text="0" FontSize="32" Foreground="White" FontWeight="Bold"/>
                        </StackPanel>
                    </Border>
                </Grid>
            </Border>
        </Grid>
        
        <!-- Footer -->
        <Border Grid.Row="2" Background="#16213e">
            <Grid Margin="25,0">
                <TextBlock VerticalAlignment="Center" Foreground="#666">
                    <Run Text="by "/><Run Text="iamrealguexoxo" Foreground="#e94560"/><Run Text=" | github.com/iamrealguexoxo/wlanpasswords"/>
                </TextBlock>
                
                <TextBlock Name="VersionText" Text="v1.0.0" HorizontalAlignment="Right" VerticalAlignment="Center" 
                          Foreground="#666" FontSize="11"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

# ============================================
# Event Handlers
# ============================================

function Load-Credentials {
    $statusText.Text = "Loading WLAN profiles..."
    $statusText.Foreground = [System.Windows.Media.Brushes]::Orange
    
    try {
        $script:credentials = Get-AllWlanCredentials
        
        if ($null -eq $script:credentials -or $script:credentials.Count -eq 0) {
            $statusText.Text = "No WLAN profiles found"
            $statusText.Foreground = [System.Windows.Media.Brushes]::Red
            $countText.Text = "Networks: 0"
            $credentialsGrid.ItemsSource = @()
            return
        }
        
        $credentialsGrid.ItemsSource = $script:credentials
        $countText.Text = "Networks: $($script:credentials.Count)"
        $statusText.Text = "Ready"
        $statusText.Foreground = [System.Windows.Media.Brushes]::Green
    }
    catch {
        $statusText.Text = "Error loading profiles: $_"
        $statusText.Foreground = [System.Windows.Media.Brushes]::Red
    }
}

function Filter-Credentials {
    param([string]$SearchTerm)
    
    if ([string]::IsNullOrWhiteSpace($SearchTerm)) {
        $credentialsGrid.ItemsSource = $script:credentials
        return
    }
    
    $filtered = $script:credentials | Where-Object { $_.SSID -like "*$SearchTerm*" }
    $credentialsGrid.ItemsSource = $filtered
}

function Show-SelectedPassword {
    $selected = $credentialsGrid.SelectedItem
    if ($null -eq $selected) {
        Show-MessageBox -Title "Information" -Message "Please select a network first" -Icon Warning
        return
    }
    
    Show-MessageBox -Title "Password for $($selected.SSID)" -Message $selected.Password
}

function Copy-SelectedPassword {
    $selected = $credentialsGrid.SelectedItem
    if ($null -eq $selected) {
        Show-MessageBox -Title "Information" -Message "Please select a network first" -Icon Warning
        return
    }
    
    [System.Windows.Forms.Clipboard]::SetText($selected.Password)
    $statusText.Text = "Password copied to clipboard"
    $statusText.Foreground = [System.Windows.Media.Brushes]::Green
}

function Export-AllPasswords {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
    $outputPath = Join-Path $desktopPath "wlan_passwords_$timestamp.txt"
    
    try {
        $content = @()
        $content += "============================================"
        $content += " WlanPasswords - WLAN Password Export"
        $content += " Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $content += "============================================"
        $content += ""
        $content += "Total profiles found: $($script:credentials.Count)"
        $content += ""
        $content += "============================================"
        
        foreach ($cred in $script:credentials) {
            $content += ""
            $content += "SSID: $($cred.SSID)"
            $content += "Password: $($cred.Password)"
            $content += "--------------------------------------------"
        }
        
        $content += ""
        $content += "============================================"
        $content += " End of Export"
        $content += "============================================"
        
        $content | Out-File -FilePath $outputPath -Encoding UTF8
        
        $statusText.Text = "Exported to Desktop"
        $statusText.Foreground = [System.Windows.Media.Brushes]::Green
        Show-MessageBox -Title "Success" -Message "Passwords exported to:`n$outputPath"
    }
    catch {
        Show-MessageBox -Title "Error" -Message "Export failed: $_" -Icon Error
    }
}

function Show-About {
    $updateInfo = Check-Version
    $updateText = ""
    
    if ($null -ne $updateInfo -and $updateInfo.UpdateAvailable) {
        $updateText = "`n`n[UPDATE AVAILABLE]`nNew version: v$($updateInfo.RemoteVersion)`nDownload: $($updateInfo.ReleaseUrl)"
    } else {
        $updateText = "`n`n[OK] You are running the latest version"
    }
    
    $aboutText = "WlanPasswords v1.0.0`n`nModern WPF GUI for extracting and managing saved WLAN passwords on Windows.`n`nAuthor: iamrealguexoxo`nGitHub: https://github.com/iamrealguexoxo/wlanpasswords`nLicense: MIT$updateText"
    
    Show-MessageBox -Title "About WlanPasswords" -Message $aboutText
}

# ============================================
# Main Window Setup
# ============================================

$reader = [System.Xml.XmlNodeReader]::new([xml]$xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Get UI Elements
$credentialsGrid = $window.FindName("CredentialsGrid")
$searchBox = $window.FindName("SearchBox")
$showPasswordButton = $window.FindName("ShowPasswordButton")
$copyPasswordButton = $window.FindName("CopyPasswordButton")
$exportButton = $window.FindName("ExportButton")
$refreshManualButton = $window.FindName("RefreshManualButton")
$refreshButton = $window.FindName("RefreshButton")
$aboutButton = $window.FindName("AboutButton")
$statusText = $window.FindName("StatusText")
$countText = $window.FindName("CountText")
$versionText = $window.FindName("VersionText")

# Wire up Events
$searchBox.Add_TextChanged({
    Filter-Credentials -SearchTerm $searchBox.Text
})

$showPasswordButton.Add_Click({
    Show-SelectedPassword
})

$copyPasswordButton.Add_Click({
    Copy-SelectedPassword
})

$exportButton.Add_Click({
    Export-AllPasswords
})

$refreshManualButton.Add_Click({
    Load-Credentials
})

$refreshButton.Add_Click({
    Load-Credentials
})

$aboutButton.Add_Click({
    Show-About
})

$window.Add_Loaded({
    Load-Credentials
    
    # Check version in background
    $updateInfo = Check-Version
    if ($null -ne $updateInfo -and $updateInfo.UpdateAvailable) {
        $versionText.Text = "v1.0.0 (update available)"
        $versionText.Foreground = [System.Windows.Media.Brushes]::Red
    }
})

# Show Window
$window.ShowDialog() | Out-Null
