# Enhanced Windows 10/11 Optimization Script
# Run as Administrator in PowerShell

Write-Host "=== Enhanced Windows Optimization Script ===" -ForegroundColor Green
Write-Host "Creating system restore point..." -ForegroundColor Yellow

# Create restore point
Checkpoint-Computer -Description "Pre-Optimization Backup" -RestorePointType "MODIFY_SETTINGS"

# Function to remove Windows apps
function Remove-WindowsApp {
    param([string]$AppName)
    try {
        Get-AppxPackage $AppName -AllUsers | Remove-AppxPackage -ErrorAction SilentlyContinue
        Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like "*$AppName*"} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        Write-Host "Removed: $AppName" -ForegroundColor Green
    } catch {
        Write-Host "Failed to remove: $AppName" -ForegroundColor Red
    }
}

# Remove bloatware apps
Write-Host "Removing bloatware apps..." -ForegroundColor Yellow
$BloatwareApps = @(
    # Communication & Social
    "Microsoft.SkypeApp",
    "Microsoft.Teams",
    "Microsoft.BingNews",
    "Microsoft.People",
    
    # Entertainment
    "Microsoft.XboxApp",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    
    # Microsoft Bloat
    "Microsoft.BingWeather",
    "Microsoft.Getstarted",
    "Microsoft.GetHelp",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsCamera",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsSoundRecorder",
    
    # Third-party bloat
    "Facebook.Facebook",
    "SpotifyAB.SpotifyMusic",
    "AdobeSystemsIncorporated.AdobePhotoshopExpress",
    "Clipchamp.Clipchamp",
    "PandoraMediaInc",
    "Disney*",
    "RoyalRevolution",
    "CandyCrush*",
    
    # Windows 11 specific
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Todos",
    "Microsoft.BingFinance",
    "Microsoft.News",
    "Microsoft.WindowsAlarms",
    "microsoft.windowscommunicationsapps"
)

foreach ($App in $BloatwareApps) {
    Remove-WindowsApp -AppName $App
}

# Completely disable Cortana via registry
Write-Host "Completely disabling Cortana..." -ForegroundColor Yellow
$CortanaPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search",
    "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Experience\AllowCortana",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
)

foreach ($Path in $CortanaPaths) {
    if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name "AllowCortana" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Path -Name "CortanaEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

# Disable Telemetry and Data Collection
Write-Host "Disabling telemetry and data collection..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableInventory" -Value 1 -Type DWord

# Disable Activity History
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -Type DWord

# Disable Game Bar and Game Mode
Write-Host "Disabling gaming features..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "Value" -Value 0 -Type DWord

# Optimize Power Plan (High Performance)
Write-Host "Optimizing power plan..." -ForegroundColor Yellow
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Set power plan settings for better performance
powercfg -change -standby-timeout-ac 0
powercfg -change -hibernate-timeout-ac 0
powercfg -change -disk-timeout-ac 0

# Disable unnecessary visual effects for performance
Write-Host "Optimizing visual effects..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Type DWord
systempropertiesperformance.exe

# Disable startup delay and optimize boot
Write-Host "Optimizing boot performance..." -ForegroundColor Yellow
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -ErrorAction SilentlyContinue
bcdedit /set {current} bootmenupolicy standard | Out-Null

# Optimize Windows Update (more control)
Write-Host "Optimizing Windows Update..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 2 -Type DWord

# Disable tips, suggestions, and ads
Write-Host "Removing ads and suggestions..." -ForegroundColor Yellow
$ContentPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
)

foreach ($Path in $ContentPaths) {
    if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name "ContentDeliveryAllowed" -Value 0 -Type DWord
    Set-ItemProperty -Path $Path -Name "OemPreInstalledAppsEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $Path -Name "PreInstalledAppsEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $Path -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $Path -Name "SubscribedContent-338387Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $Path -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $Path -Name "SubscribedContent-353696Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $Path -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord
}

# Disable background apps completely
Write-Host "Disabling background apps..." -ForegroundColor Yellow
Get-AppxPackage -AllUsers | ForEach-Object {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" -ErrorAction SilentlyContinue}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord

# Optimize services for performance
Write-Host "Optimizing services..." -ForegroundColor Yellow
$ServicesToDisable = @(
    # Xbox Services
    "XboxGipSvc",
    "XboxNetApiSvc",
    
    # Telemetry & Tracking
    "DiagTrack",
    "dmwappushservice",
    "WpcMonSvc",
    
    # Unnecessary features
    "TabletInputService",
    "lfsvc",
    "MapsBroker",
    "SharedAccess",
    "lltdsvc",
    "PeerDistSvc",
    
    # Print Spooler (enable if you use printers)
    # "Spooler",
    
    # Remote Registry
    "RemoteRegistry",
    
    # Windows Search (disable if you don't use file search)
    # "WSearch",
    
    # Bluetooth Support (disable if not using Bluetooth)
    "BthAvctpSvc",
    
    # Phone services
    "PhoneSvc",
    
    # Connected User Experiences
    "UserDataSvc"
)

foreach ($service in $ServicesToDisable) {
    try {
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Write-Host "Disabled service: $service" -ForegroundColor Green
    } catch {
        Write-Host "Could not disable service: $service" -ForegroundColor Red
    }
}

# Network optimizations for better performance
Write-Host "Optimizing network settings..." -ForegroundColor Yellow
$NetworkPaths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters",
    "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
)

foreach ($Path in $NetworkPaths) {
    Set-ItemProperty -Path $Path -Name "EnablePMTUDiscovery" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Path -Name "EnablePMTUBHDetect" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Path -Name "Tcp1323Opts" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $Path -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
}

# Disable Windows Error Reporting
Write-Host "Disabling error reporting..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1 -Type DWord

# Optimize Windows Explorer
Write-Host "Optimizing Windows Explorer..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Type DWord

# Clean temporary files and optimize storage
Write-Host "Cleaning temporary files..." -ForegroundColor Yellow
Cleanmgr /sagerun:1 | Out-Null

# Run disk cleanup and optimization
Write-Host "Optimizing storage..." -ForegroundColor Yellow
Optimize-Volume -DriveLetter C -ReTrim -ErrorAction SilentlyContinue
Optimize-Volume -DriveLetter C -Defrag -ErrorAction SilentlyContinue

# Disable hibernation (saves disk space = RAM size)
Write-Host "Disabling hibernation..." -ForegroundColor Yellow
powercfg -h off

# Disable System Restore on non-system drives (optional)
Write-Host "Configuring System Restore..." -ForegroundColor Yellow
Disable-ComputerRestore -Drive "D:\" -ErrorAction SilentlyContinue
Disable-ComputerRestore -Drive "E:\" -ErrorAction SilentlyContinue

# Enable ultimate performance power plan (Windows 10/11 Pro)
Write-Host "Enabling Ultimate Performance power plan..." -ForegroundColor Yellow
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61

# Disable Widgets (Windows 11)
Write-Host "Disabling Widgets..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Value 0 -Type DWord

# Disable News and Interests
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2 -Type DWord

Write-Host "`n=== OPTIMIZATION COMPLETED ===" -ForegroundColor Green
Write-Host "Summary of changes:" -ForegroundColor Cyan
Write-Host "✓ Removed bloatware apps (Skype, Cortana, Xbox, etc.)" -ForegroundColor White
Write-Host "✓ Disabled telemetry and data collection" -ForegroundColor White
Write-Host "✓ Optimized power plan for performance" -ForegroundColor White
Write-Host "✓ Disabled unnecessary services" -ForegroundColor White
Write-Host "✓ Optimized network settings" -ForegroundColor White
Write-Host "✓ Cleaned temporary files" -ForegroundColor White
Write-Host "✓ Disabled ads and suggestions" -ForegroundColor White
Write-Host "`nIMPORTANT: Restart your computer for all changes to take effect!" -ForegroundColor Yellow
Write-Host "Some removed apps can be reinstalled from Microsoft Store if needed." -ForegroundColor Cyan
