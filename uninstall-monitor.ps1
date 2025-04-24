# Uninstall script for MyMonitorApp

# Define paths
$configDir = Join-Path $env:APPDATA "MyMonitorApp"
$configPath = Join-Path $configDir "config.json"
$startupFolder = [Environment]::GetFolderPath("Startup")
$shortcutPath = Join-Path $startupFolder "MyMonitorApp.lnk"
# $exePath = "C:\Path\To\monitor.exe"  # Uncomment and set to delete the exe

# Stop the running exe if it's running
$processName = "monitor"  # Change to match your exe's process name without .exe
$process = Get-Process -Name $processName -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Name $processName -Force
    Write-Host "Stopped the running process."
} else {
    Write-Host "No running process found."
}

# Delete config file and directory
if (Test-Path $configDir) {
    Remove-Item $configDir -Recurse -Force
    Write-Host "Deleted configuration directory and files."
} else {
    Write-Host "Configuration directory not found."
}

# Remove shortcut
if (Test-Path $shortcutPath) {
    Remove-Item $shortcutPath -Force
    Write-Host "Removed shortcut from Startup."
} else {
    Write-Host "Shortcut not found in Startup."
}

# Optionally, delete the exe file
# if (Test-Path $exePath) {
#     Remove-Item $exePath -Force
#     Write-Host "Deleted exe file."
# } else {
#     Write-Host "Exe file not found."
# }

Write-Host "Uninstallation complete."
