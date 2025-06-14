# 01-initial-setup.ps1
# Initial Windows configuration for Commando VM build

Write-Host "=== Starting Initial Windows Configuration ===" -ForegroundColor Green

# Function to write timestamped logs
function Write-Log {
    param($Message, $Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

Write-Log "Disabling Windows Defender real-time protection temporarily..." "Yellow"
try { 
    Set-MpPreference -DisableRealtimeMonitoring $true 
    Write-Log "Windows Defender real-time protection disabled" "Green"
} catch { 
    Write-Log "Could not disable Windows Defender - continuing anyway" "Yellow"
}

Write-Log "Setting execution policy..."
Set-ExecutionPolicy Bypass -Scope LocalMachine -Force
Set-ExecutionPolicy Bypass -Scope Process -Force

Write-Log "Configuring security protocols..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

Write-Log "Installing Chocolatey package manager..." "Cyan"
$maxRetries = 3
$retryCount = 0
$chocoInstalled = $false

do {
    try {
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        $chocoInstalled = $true
        Write-Log "Chocolatey installed successfully" "Green"
    } catch {
        $retryCount++
        Write-Log "Chocolatey installation failed, attempt $retryCount of $maxRetries" "Red"
        if ($retryCount -lt $maxRetries) {
            Write-Log "Waiting 30 seconds before retry..." "Yellow"
            Start-Sleep 30
        }
    }
} while (-not $chocoInstalled -and $retryCount -lt $maxRetries)

if (-not $chocoInstalled) {
    Write-Log "Failed to install Chocolatey after $maxRetries attempts" "Red"
    throw "Chocolatey installation failed"
}

Write-Log "Installing Git..." "Cyan"
try {
    choco install git -y --force --no-progress
    Write-Log "Git installed successfully" "Green"
} catch {
    Write-Log "Git installation failed" "Red"
    throw "Git installation failed"
}

Write-Log "Refreshing environment variables..."
refreshenv

# Verify Git installation
try {
    $gitVersion = git --version
    Write-Log "Git version: $gitVersion" "Green"
} catch {
    Write-Log "Git verification failed" "Yellow"
}

Write-Log "=== Initial Configuration Completed ===" -ForegroundColor Green