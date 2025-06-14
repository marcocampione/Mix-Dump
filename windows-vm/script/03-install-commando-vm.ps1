# 03-install-commando-vm.ps1
# Install Commando VM tools and packages

Write-Host "=== Installing Commando VM ===" -ForegroundColor Green

# Function to write timestamped logs
function Write-Log {
    param($Message, $Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

Write-Log "Navigating to Commando VM directory..."
Set-Location C:\commando-vm

Write-Log "Setting unrestricted execution policy for installation..."
Set-ExecutionPolicy Unrestricted -Force

Write-Log "Listing available Commando VM packages..." "Cyan"
try {
    .\install.ps1 -ListOnly
    Write-Log "Package listing completed successfully" "Green"
} catch {
    Write-Log "Package listing failed: $($_.Exception.Message)" "Yellow"
    Write-Log "Continuing with installation anyway..." "Yellow"
}

Write-Log "Starting Commando VM installation..." "Cyan"
Write-Log "This may take 30-60 minutes depending on internet speed..." "Yellow"

# Capture start time
$startTime = Get-Date

try {
    # Run Commando VM installation with error handling
    .\install.ps1 -Force
    
    $endTime = Get-Date
    $duration = $endTime - $startTime
    Write-Log "Commando VM installation completed successfully" "Green"
    Write-Log "Installation duration: $($duration.TotalMinutes.ToString('F1')) minutes" "Green"
    
} catch {
    $endTime = Get-Date
    $duration = $endTime - $startTime
    Write-Log "Commando VM installation encountered errors after $($duration.TotalMinutes.ToString('F1')) minutes" "Red"
    Write-Log "Error details: $($_.Exception.Message)" "Red"
    Write-Log "Continuing with build process..." "Yellow"
    
    # Don't throw here as some tools might still have installed successfully
}

# Verify installation
Write-Log "Verifying Commando VM installation..." "Cyan"

$toolsPath = "C:\tools"
if (Test-Path $toolsPath) {
    $toolCount = (Get-ChildItem $toolsPath -Directory -ErrorAction SilentlyContinue).Count
    Write-Log "Tools directory found with $toolCount subdirectories" "Green"
    
    # List some key tools
    $keyTools = @("volatility", "windbg", "ida", "ghidra", "wireshark", "burp")
    foreach ($tool in $keyTools) {
        $toolPath = Join-Path $toolsPath $tool
        if (Test-Path $toolPath) {
            Write-Log "  ✓ $tool found" "Green"
        }
    }
} else {
    Write-Log "Tools directory not found - installation may have issues" "Yellow"
}

# Check for common Commando VM shortcuts on desktop
$desktopPath = "C:\Users\Public\Desktop"
if (Test-Path $desktopPath) {
    $shortcuts = Get-ChildItem $desktopPath -Filter "*.lnk" -ErrorAction SilentlyContinue
    Write-Log "Found $($shortcuts.Count) desktop shortcuts" "Green"
}

Write-Log "=== Commando VM Installation Phase Completed ===" "Green"