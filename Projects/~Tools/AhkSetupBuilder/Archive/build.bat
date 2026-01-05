
FOR /R %%f IN (*.iss) DO (

    rem echo %%f
	
	"C:\Program Files (x86)\Inno Setup 6\iscc.exe" "%%f"
)

pause