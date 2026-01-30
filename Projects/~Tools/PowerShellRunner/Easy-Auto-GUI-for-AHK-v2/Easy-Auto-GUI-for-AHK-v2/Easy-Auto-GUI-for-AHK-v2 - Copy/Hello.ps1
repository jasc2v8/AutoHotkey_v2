Write-Output "Hello from PowerShell!"
Write-Output "Checking Admin Status..."
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
Write-Output "Is Admin: $isAdmin"
Write-Output "Current Time: $(Get-Date)"