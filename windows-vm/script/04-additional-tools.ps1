# 04-additional-tools.ps1
# Install additional security tools and configure environment

Write-Host "=== Installing Additional Security Tools ===" -ForegroundColor Green

# Function to write timestamped logs
function Write-Log {
    param($Message, $Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

# Function to install package with retry logic
function Install-Package {
    param($PackageName, $MaxRetries = 2)
    
    for ($i = 1; $i -le $MaxRetries; $i++) {
        try {
            Write-Log "Installing $PackageName (attempt $i)..." "Cyan"
            choco install $PackageName -y --ignore-checksums --no-progress --force
            Write-Log "$PackageName installed successfully" "Green"
            return $true
        } catch {
            Write-Log "$PackageName installation failed: $($_.Exception.Message)" "Yellow"
            if ($i -lt $MaxRetries) {
                Write-Log "Retrying $PackageName installation..." "Yellow"
                Start-Sleep 10
            }
        }
    }
    Write-Log "$PackageName installation failed after $MaxRetries attempts" "Red"
    return $false
}

# Essential security tools
$securityTools = @(
    "sysinternals",
    "wireshark", 
    "nmap",
    "notepadplusplus",
    "7zip",
    "firefox",
    "putty",
    "winscp",
    "processhacker",
    "hexchat"
)

Write-Log "Installing essential security tools..." "Cyan"
foreach ($tool in $securityTools) {
    Install-Package $tool
}

Write-Log "Creating security tools directory structure..." "Cyan"
$securityDirs = @(
    "C:\SecurityTools",
    "C:\SecurityTools\Scripts",
    "C:\SecurityTools\Samples",
    "C:\SecurityTools\Reports",
    "C:\SecurityTools\Custom",
    "C:\SecurityTools\Logs"
)

foreach ($dir in $securityDirs) {
    try {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Log "Created directory: $dir" "Green"
    } catch {
        Write-Log "Failed to create directory: $dir" "Red"
    }
}

Write-Log "Configuring Windows Defender exclusions..." "Cyan"
$exclusionPaths = @(
    "C:\SecurityTools",
    "C:\commando-vm", 
    "C:\tools",
    "C:\temp",
    "C:\malware_samples"
)

foreach ($path in $exclusionPaths) {
    try {
        Add-MpPreference -ExclusionPath $path -ErrorAction SilentlyContinue
        Write-Log "Added exclusion for: $path" "Green"
    } catch {
        Write-Log "Could not add exclusion for: $path" "Yellow"
    }
}

# Re-enable Windows Defender with exclusions
try {
    Set-MpPreference -DisableRealtimeMonitoring $false
    Write-Log "Windows Defender real-time protection re-enabled with exclusions" "Green"
} catch {
    Write-Log "Could not re-enable Windows Defender" "Yellow"
}

Write-Log "Creating useful PowerShell profile..." "Cyan"
$profileContent = @"
# Custom PowerShell profile for security research
Set-Location C:\SecurityTools
Write-Host "Security Research Environment Loaded" -ForegroundColor Green
Write-Host "Tools Location: C:\tools" -ForegroundColor Cyan
Write-Host "Custom Tools: C:\SecurityTools" -ForegroundColor Cyan

# Useful aliases
Set-Alias ll Get-ChildItem
Set-Alias grep Select-String

# Function to quickly navigate to tools
function tools { Set-Location C:\tools }
function security { Set-Location C:\SecurityTools }

Write-Host "Type 'tools' or 'security' to navigate to tool directories" -ForegroundColor Yellow
"@

try {
    $profilePath = $PROFILE.AllUsersAllHosts
    $profileDir = Split-Path $profilePath -Parent
    if (!(Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }
    $profileContent | Out-File -FilePath $profilePath -Encoding UTF8
    Write-Log "PowerShell profile created at: $profilePath" "Green"
} catch {
    Write-Log "Could not create PowerShell profile" "Yellow"
}

Write-Log "Installing Python packages for security research..." "Cyan"
try {
    # Install Python if not already present
    if (!(Get-Command python -ErrorAction SilentlyContinue)) {
        choco install python -y --no-progress
    }
    
    # Install useful Python packages
    python -m pip install --upgrade pip
    python -m pip install requests beautifulsoup4 pycrypto scapy
    Write-Log "Python packages installed" "Green"
} catch {
    Write-Log "Python package installation failed" "Yellow"
}

Write-Log "=== Additional Tools Installation Completed ===" "Green"