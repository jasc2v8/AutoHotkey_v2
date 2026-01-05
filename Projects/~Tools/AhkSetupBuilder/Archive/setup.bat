
rem verification of Inno Setup command line with multiple paramters
rem next step is to write make_iss.ahk and compile into make_iss.exe that will:
rem    find the exe file, extract file info, build a command line like the one below, then run it
rem how to find the correct .ahk file?
rem perhaps loop to find all .ahk files and compile each.  see: make_iss.bat

"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" /DMyAppName="My Application" ^
/DMyAppVersion="9.9" FindExeExample.iss

pause
