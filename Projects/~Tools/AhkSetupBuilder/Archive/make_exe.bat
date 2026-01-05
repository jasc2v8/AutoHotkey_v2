
@echo off

FOR /R %%f IN (*.ahk) DO (
 
    @echo Making: %%f

    "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" ^
    /in "%%f" ^
    /out "%%~dpf%%~nf.exe" ^
    /icon "%%~dpf%%~nf.ico" ^
    /base "C:\Program Files\AutoHotkey\v2\AutoHotKey64.exe"
)

@echo Done!

pause