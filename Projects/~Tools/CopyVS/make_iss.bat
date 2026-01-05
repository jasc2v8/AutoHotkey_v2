@echo off

FOR /R %%f IN (*.iss) DO (

    @echo %%f
	
	"C:\Program Files (x86)\Inno Setup 6\iscc.exe" "%%f"
)

pause