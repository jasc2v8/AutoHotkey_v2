@echo off

echo User PATH
REG QUERY "HKCU\Environment" /v Path

net session >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo SUCCESS: Running with Administrator privileges.
    echo.
) else (
    echo.
    echo  FAILURE: Running with standard user privileges.
    echo.
	exit
)

echo System PATH
REG QUERY "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path

pause
