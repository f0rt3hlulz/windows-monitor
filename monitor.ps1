# Define config path
$configDir = Join-Path $env:APPDATA "MyMonitorApp"
$configPath = Join-Path $configDir "config.json"

# Create config dir if not exists
if (-not (Test-Path $configDir)) {
    New-Item -Path $configDir -ItemType Directory | Out-Null
}

# Check if config exists; if not, prompt for inputs
if (-not (Test-Path $configPath)) {
    $token = Read-Host "Enter Telegram bot token"
    $chatId = Read-Host "Enter Telegram chat ID"
    $processName = Read-Host "Enter process name to monitor"

    # Save to config.json
    $config = @{
        token = $token
        chatId = $chatId
        processName = $processName
    } | ConvertTo-Json
    Set-Content -Path $configPath -Value $config
} else {
    $config = Get-Content -Path $configPath | ConvertFrom-Json
    $token = $config.token
    $chatId = $config.chatId
    $processName = $config.processName
}

# If running as EXE, add to startup if not already added
if ($MyInvocation.MyCommand.Path -like "*.exe") {
    $startupFolder = [Environment]::GetFolderPath("Startup")
    $shortcutPath = Join-Path $startupFolder "MyMonitorApp.lnk"
    if (-not (Test-Path $shortcutPath)) {
        $wshell = New-Object -ComObject WScript.Shell
        $shortcut = $wshell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $MyInvocation.MyCommand.Path  # EXE path
        $shortcut.Save()
    }
}

# Define Send-TelegramMessage function
function Send-TelegramMessage {
    param (
        [string]$token,
        [string]$chatId,
        [string]$message
    )
    $body = @{
        chat_id = $chatId
        text = $message
    }
    $url = "https://api.telegram.org/bot$token/sendMessage"
    try {
        Invoke-RestMethod -Uri $url -Method Post -Body ($body | ConvertTo-Json) -ContentType "application/json"
        Write-Host "Alert sent: $message"
    } catch {
        Write-Host "Failed to send alert: $_"
    }
}

# Initialize state
$wasDown = $false

# Monitoring loop
while ($true) {
    $process = Get-Process -Name $processName -ErrorAction SilentlyContinue
    $isDown = -not $process
    if ($isDown -and -not $wasDown) {
        $message = "Alert: The app '$processName' is down on $env:COMPUTERNAME at $(Get-Date)!"
        Send-TelegramMessage -token $token -chatId $chatId -message $message
    }
    $wasDown = $isDown
    Start-Sleep -Seconds 60  # Check every minute
}
