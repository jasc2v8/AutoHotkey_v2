# TITLE  : RebuildFontCache v1.0
# SOURCE : jasc2v8
# LICENSE: The Unlicense, see https://unlicense.org
# PURPOSE: Stops font services, deletes cache files, and restarts services to fix font issues.

# 1. Stop Services
# Using -ErrorAction SilentlyContinue in case the service is already stopped
Write-Host "Stopping Font Services..." -ForegroundColor Cyan
Stop-Service -Name "FontCache" -Force -ErrorAction SilentlyContinue
Stop-Service -Name "FontCache3.0.0.0" -Force -ErrorAction SilentlyContinue

# 2. Delete cache files
$WinDir = $env:WinDir
$Paths = @(
    "$WinDir\ServiceProfiles\LocalService\AppData\Local\FontCache\*.dat",
    "$WinDir\System32\FNTCACHE.DAT"
)

$FolderToClear = "$WinDir\ServiceProfiles\LocalService\AppData\Local\FontCache\Fonts"

Write-Host "Clearing cache files..." -ForegroundColor Cyan

try {
    # Remove files
    foreach ($Path in $Paths) {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Force
        }
    }

    # Remove the Fonts folder and its contents (similar to DirDelete , 1)
    if (Test-Path $FolderToClear) {
        Remove-Item -Path $FolderToClear -Recurse -Force
    }
    
    Write-Host "Cache cleared successfully." -ForegroundColor Green
}
catch {
    Write-Warning "Some files could not be deleted. They may be in use."
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. Restart the main service
Write-Host "Restarting FontCache service..." -ForegroundColor Cyan
Start-Service -Name "FontCache"

Write-Host "Process Complete!" -ForegroundColor Green