#Requires AutoHotkey v2.0
#SingleInstance Force
;#NoTrayIcon

;DEBUG
#Include <Debug>
Escape::ExitApp()

class MsgBoxEx
{
   static MyGui := unset
   static Result := unset

    fileName := ''
    dir := ''
    ext := ''
    nameNoExt := ''
    drive := ''
    fullPath := ''
    parentDir := ''

    ; Constructor method
    __New(pathString)
    {
        SplitPath(pathString, &fileName, &dir, &ext, &nameNoExt, &drive)
        SplitPath(dir, &parentDir)

        this.fileName := fileName
        this.dir := dir
        this.ext := ext
        this.nameNoExt := nameNoExt
        this.drive := drive
        this.fullPath := pathString
        this.parentDir := parentDir
    }

    Show(text, title)
    {
      this.MyGui := Gui()
      this.MyGui.Title := title
      this.MyGui.AddText(,text)
      ; works this.MyGui.AddButton("Default","&OK").OnEvent("Click", (p1, p2) => this.MyGui.Destroy())
      this.MyGui.AddButton("Default","&OK").OnEvent("Click", this.Button_Click.Bind(this))
      this.Result := this.MyGui.Show()
      WinWaitClose(this.MyGui)
        
    }

    Button_Click(GuiCtrl, Info)
    {
      PostMessage(WM_CLOSE:=0x10, 0, 0, this.MyGui.Hwnd)
      return this.Result

    }
}

; --- Usage Example ---

MB := MsgBoxEx('param')
r := MB.Show("text", "title")
MsgBox("You Pressed: [" r "]")

