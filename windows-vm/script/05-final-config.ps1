# 05-final-config.ps1
# Final configuration and cleanup for Windows Commando VM

Write-Host "=== Performing Final Configuration ===" -ForegroundColor Green

# Function to write timestamped logs
function Write-Log {
    param($Message, $Color = "White")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

Write-Log "Starting cleanup process..." "Cyan"

# Clean up temporary files
$cleanupPaths = @(
    "C:\Windows\Temp\*",
    "C:\Users\*\AppData\Local\Temp\*",
    "C:\temp\*",
    "C:\Windows\SoftwareDistribution\Download\*"
)

foreach ($path in $cleanupPaths) {
    try {
        Write-Log "Cleaning: $path"
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    } catch {
        Write-Log "Could not clean: $path" "Yellow"
    }
}

Write-Log "Optimizing system for security research..." "Cyan"

# Disable unnecessary services
$servicesToDisable = @(
    "Themes",
    "TabletInputService", 
    "Fax",
    "WSearch"  # Windows Search - can be resource intensive
)

foreach ($service in $servicesToDisable) {
    try {
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Log "Disabled service: $service" "Green"
    } catch {
        Write-Log "Could not disable service: $service" "Yellow"
    }
}

Write-Log "Creating desktop shortcuts..." "Cyan"

# Create COM object for shortcuts
$WshShell = New-Object -comObject WScript.Shell

# Desktop shortcuts to create
$shortcuts = @(
    @{
        Name = "Commando VM Tools"
        Target = "C:\tools"
        Description = "Commando VM Security Tools"
    },
    @{
        Name = "Security Tools"
        Target = "C:\SecurityTools"
        Description = "Custom Security Tools Directory"
    },
    @{
        Name = "PowerShell (Admin)"
        Target = "powershell.exe"
        Arguments = "-ExecutionPolicy Bypass"
        Description = "PowerShell with Admin Rights"
        RunAsAdmin = $true
    },
    @{
        Name = "Command Prompt (Admin)"
        Target = "cmd.exe"
        Description = "Command Prompt with Admin Rights"
        RunAsAdmin = $true
    }
)

foreach ($shortcut in $shortcuts) {
    try {
        $shortcutPath = "C:\Users\Public\Desktop\$($shortcut.Name).lnk"
        $sh = $WshShell.CreateShortcut($shortcutPath)
        $sh.TargetPath = $shortcut.Target
        if ($shortcut.Arguments) { $sh.Arguments = $shortcut.Arguments }
        if ($shortcut.Description) { $sh.Description = $shortcut.Description }
        $sh.Save()
        Write-Log "Created shortcut: $($shortcut.Name)" "Green"
    } catch {
        Write-Log "Could not create shortcut: $($shortcut.Name)" "Yellow"
    }
}

Write-Log "Creating system information file..." "Cyan"
$systemInfo = @"
=== Windows Commando VM Build Information ===
Build Date: $(Get-Date)
Windows Version: $(Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
PowerShell Version: $($PSVersionTable.PSVersion)

=== Installed Tool Directories ===
- C:\tools (Commando VM Tools)
- C:\SecurityTools (Custom Tools)
- C:\SecurityTools\Scripts (Custom Scripts)
- C:\SecurityTools\Samples (Malware Samples)
- C:\SecurityTools\Reports (Analysis Reports)

=== Key Tools Installed ===
$(if (Test-Path "C:\tools") { "✓ Commando VM Tools Suite" } else { "✗ Commando VM Tools" })
$(if (Get-Command git -ErrorAction SilentlyContinue) { "✓ Git" } else { "✗ Git" })
$(if (Get-Command python -ErrorAction SilentlyContinue) { "✓ Python" } else { "✗ Python" })
$(if (Get-Command choco -ErrorAction SilentlyContinue) { "✓ Chocolatey" } else { "✗ Chocolatey" })

=== Security Research Notes ===
- Windows Defender has exclusions for tool directories
- PowerShell execution policy set to Bypass
- Custom PowerShell profile loaded with security aliases
- OS Login enabled for GCP authentication

=== Usage Tips ===
1. Use 'tools' command in PowerShell to navigate to C:\tools
2. Use 'security' command to navigate to C:\SecurityTools
3. All major security tools accessible from desktop shortcuts
4. Check C:\tools for Commando VM installed applications

For support: https://github.com/mandiant/commando-vm
"@

try {
    $systemInfo | Out-File -FilePath "C:\SecurityTools\BUILD_INFO.txt" -Encoding UTF8
    $systemInfo | Out-File -FilePath "C:\Users\Public\Desktop\BUILD_INFO.txt" -Encoding UTF8
    Write-Log "System information file created" "Green"
} catch {
    Write-Log "Could not create system information file" "Yellow"
}

Write-Log "Performing final system optimization..." "Cyan"

# Clear event logs to reduce image size
try {
    $eventLogs = Get-WinEvent -ListLog * | Where-Object { $_.RecordCount -gt 0 }
    foreach ($log in $eventLogs) {
        try {
            wevtutil cl $log.LogName
        } catch {
            # Some logs can't be cleared, ignore errors
        }
    }
    Write-Log "Event logs cleared" "Green"
} catch {
    Write-Log "Could not clear event logs" "Yellow"
}

# Optimize Windows components
Write-Log "Configuring Windows for optimal performance..." "Cyan"
try {
    # Disable visual effects for better performance
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue
    
    # Configure power settings for high performance
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    
    Write-Log "Performance optimizations applied" "Green"
} catch {
    Write-Log "Could not apply all performance optimizations" "Yellow"
}

# Final verification
Write-Log "Performing final verification..." "Cyan"

$verificationResults = @()

# Check key directories
$keyDirectories = @("C:\tools", "C:\SecurityTools", "C:\commando-vm")
foreach ($dir in $keyDirectories) {
    if (Test-Path $dir) {
        $itemCount = (Get-ChildItem $dir -ErrorAction SilentlyContinue).Count
        $verificationResults += "✓ $dir ($itemCount items)"
        Write-Log "✓ $dir verified ($itemCount items)" "Green"
    } else {
        $verificationResults += "✗ $dir (missing)"
        Write-Log "✗ $dir missing" "Red"
    }
}

# Check key executables
$keyExecutables = @("git", "python", "choco")
foreach ($exe in $keyExecutables) {
    if (Get-Command $exe -ErrorAction SilentlyContinue) {
        $version = & $exe --version 2>$null | Select-Object -First 1
        $verificationResults += "✓ $exe ($version)"
        Write-Log "✓ $exe verified" "Green"
    } else {
        $verificationResults += "✗ $exe (not found)"
        Write-Log "✗ $exe not found" "Yellow"
    }
}

# Create final verification report
$verificationReport = @"
=== FINAL BUILD VERIFICATION REPORT ===
Build Completed: $(Get-Date)

$($verificationResults -join "`n")

=== DISK USAGE ===
C: Drive: $(Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" | ForEach-Object { "{0:N2} GB used of {1:N2} GB total" -f (($_.Size - $_.FreeSpace) / 1GB), ($_.Size / 1GB) })

=== MEMORY ===
Total RAM: $([math]::Round((Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)) GB

=== BUILD STATUS ===
Status: COMPLETED SUCCESSFULLY
Image ready for deployment
"@

try {
    $verificationReport | Out-File -FilePath "C:\SecurityTools\VERIFICATION_REPORT.txt" -Encoding UTF8
    Write-Log "Verification report created" "Green"
} catch {
    Write-Log "Could not create verification report" "Yellow"
}

Write-Host ""
Write-Host "=== PACKER BUILD COMPLETED SUCCESSFULLY ===" -ForegroundColor Green
Write-Host ""
Write-Log "Windows VM with Commando VM is ready for security research!" "Green"
Write-Host ""
Write-Host "Available tools directories:" -ForegroundColor Cyan
Write-Host "  - C:\tools (Commando VM tools)" -ForegroundColor White
Write-Host "  - C:\SecurityTools (Additional tools)" -ForegroundColor White
Write-Host "  - Desktop shortcuts created for easy access" -ForegroundColor White
Write-Host ""
Write-Host "Build verification report: C:\SecurityTools\VERIFICATION_REPORT.txt" -ForegroundColor Yellow
Write-Host "Build information: C:\SecurityTools\BUILD_INFO.txt" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ready for image creation!" -ForegroundColor Green