# Get the path to the desktop
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, "Desktop")
$logFile = Join-Path $PSScriptRoot "AHK_Test_Log.txt"

# Check if running as Admin
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Create a message
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$message = "[$timestamp] Admin Status: $isAdmin"

# Log the result to a file on your desktop
Add-Content -Path $logFile -Value $message

# Optional: Add a 2-second delay so you can see the process in Task Manager if you're quick
# Start-Sleep -Seconds 2
