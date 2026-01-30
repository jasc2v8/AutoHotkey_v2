Stop-Process -Name explorer -Force
# Explorer usually restarts itself automatically, 
# but this line ensures it launches if it doesn't.
Start-Process explorer.exe
# Read-Host -Prompt "Press Enter to exit"