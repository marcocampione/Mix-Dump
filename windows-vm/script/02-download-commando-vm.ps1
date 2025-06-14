# 02-download-commando-vm.ps1
# Download and prepare Commando VM repository

Write-Host "=== Downloading Commando VM ===" -ForegroundColor Green

# Function to write timestamped logs
function Write-Log {
    param($Message, $Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

Write-Log "Setting working directory to C:\"
Set-Location C:\

Write-Log "Configuring Git settings for the build..."
try {
    git config --global user.email "packer@build.local"
    git config --global user.name "Packer Build"
    git config --global init.defaultBranch main
    Write-Log "Git configuration completed" "Green"
} catch {
    Write-Log "Git configuration failed, continuing anyway..." "Yellow"
}

Write-Log "Cloning Commando VM repository..." "Cyan"

# Remove existing directory if it exists
if (Test-Path 'C:\commando-vm') {
    Write-Log "Removing existing commando-vm directory..."
    Remove-Item -Path 'C:\commando-vm' -Recurse -Force -ErrorAction SilentlyContinue
}

# Clone with retry logic
$maxRetries = 3
$retryCount = 0
$cloneSuccess = $false

do {
    try {
        Write-Log "Clone attempt $($retryCount + 1) of $maxRetries..."
        
        # Use HTTPS clone with specific options for better reliability
        git clone --depth 1 --single-branch https://github.com/mandiant/commando-vm.git
        
        if (Test-Path 'C:\commando-vm') {
            $cloneSuccess = $true
            Write-Log "Commando VM repository cloned successfully" "Green"
        } else {
            throw "Directory not created after clone"
        }
    } catch {
        $retryCount++
        Write-Log "Git clone failed: $($_.Exception.Message)" "Red"
        
        if ($retryCount -lt $maxRetries) {
            Write-Log "Waiting 30 seconds before retry..." "Yellow"
            Start-Sleep 30
            
            # Clean up any partial clone
            if (Test-Path 'C:\commando-vm') {
                Remove-Item -Path 'C:\commando-vm' -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
} while (-not $cloneSuccess -and $retryCount -lt $maxRetries)

if (-not $cloneSuccess) {
    Write-Log "Failed to clone Commando VM repository after $maxRetries attempts" "Red"
    throw "Failed to clone Commando VM repository"
}

# Verify the clone
Write-Log "Verifying cloned repository..."
Set-Location C:\commando-vm

if (Test-Path "install.ps1") {
    Write-Log "install.ps1 found - repository clone verified" "Green"
} else {
    Write-Log "install.ps1 not found - repository clone may be incomplete" "Red"
    throw "Commando VM repository incomplete"
}

# List repository contents for verification
Write-Log "Repository contents:"
Get-ChildItem -Name | ForEach-Object { Write-Log "  - $_" "Gray" }

Write-Log "=== Commando VM Download Completed ===" "Green"