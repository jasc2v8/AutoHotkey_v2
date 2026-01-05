#Requires AutoHotkey v2.0

;#Include <RunAsAdmin>

CLSID := "{2F6D1410-B14D-4F71-A2A2-B67D3D22467D}"

try {
    ; Access the object from the ROT
    RemoteObj := ComObjActive(CLSID)
    
    MsgBox("Successfully connected!`n" 
           "Message: " RemoteObj.Message "`n"
           "Calculation (5+5): " RemoteObj.Add(5, 5))
} catch {
    MsgBox("Failed to connect. Is the Admin script running?")
}