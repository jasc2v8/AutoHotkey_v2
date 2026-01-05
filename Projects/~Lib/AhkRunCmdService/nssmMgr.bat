
@ECHO OFF
: CLS

:MENU_START
CLS
ECHO.
ECHO ====================================
ECHO  nssm Manager
ECHO ====================================
ECHO 1. nssm Install
ECHO 2. nssm Start
ECHO 3. nssm Stop
ECHO 4. nssm Remove
ECHO 5. nssm Create
ECHO 6. Exit Program
ECHO.

:: ----------------------------------------------------
:: 1. Get User Input
:: /C:123 sets the valid choices to 1, 2, and 3.
:: /N hides the default prompt [1,2,3]?
:: /M "..." sets the custom prompt message.
:: The CHOICE command sets the ERRORLEVEL to 1, 2, or 3.
:: ----------------------------------------------------
CHOICE /C:123456 /N /M "Enter your choice (1-3):"

:: ----------------------------------------------------
:: 2. Route Based on ERRORLEVEL
:: Uses the ERRORLEVEL value (1, 2, or 3) to dynamically jump 
:: to the corresponding label (e.g., :ACTION-1, :ACTION-2).
:: ----------------------------------------------------
SET CHOICE_INDEX=%ERRORLEVEL%
GOTO :ACTION-%CHOICE_INDEX%

:: ====================================
:: ACTION HANDLERS
:: ====================================

:ACTION-1
ECHO.
ECHO --- 1. Install & Start ---
nssm install AhkRunCmdService "D:\Software\DEV\Work\AHK2\Projects\AhkRunCmdService\AhkRunCmdService.exe"
nssm set AhkRunCmdService Objectname .\Jim Pmi$10707
nssm start AhkRunCmdService
PAUSE
GOTO :MENU_START  :: *** LOOP: Returns to the start of the menu

:ACTION-2
ECHO.
ECHO --- 2. Opening Explorer ---
START explorer.exe
GOTO :MENU_START  :: *** LOOP: Returns to the start of the menu

:ACTION-3
ECHO.
ECHO Exiting the program. Goodbye!
EXIT /B  :: EXITS: Stops the batch script

:: ====================================
:: FALLBACK (Should not be reached if choices are restricted by /C)
:: ====================================
:EOF


