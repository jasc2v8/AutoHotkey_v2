#Requires AutoHotkey v2.0+
#SingleInstance Force
;#NoTrayIcon

;DEBUG
#Include <Debug>
Escape::ExitApp()

GuiAhkPad := CustomGui()

class CustomGui extends Gui
{
    __New(Title := "Untitled - AhkPad") {
        ; this.MainGui := Gui("+Resize", '', this)
        super.__New("+Resize", '', this)
        this.FilePath := ""
        this.MarginX := -2
        this.MarginY := -2

        ; Create the main Edit control:
        this.MainEdit := this.AddEdit("vMainEdit +HScroll +VScroll +0x100 -Wrap WantTab W600 R20", "")
        this.MainEdit.OnEvent("Change", "MainEdit_Change")
        this.MainEdit.OnEvent("Focus", "SB_Redraw")
        this.MainEdit.OnEvent("LoseFocus", "SB_Redraw")
        this.MainEdit.SetFont("s11", "Consolas")

        ; Create the submenus for the menu bar:
        this.FileMenu := Menu()
        this.FileMenu.Add("&New`tCtrl+N", this.MenuFileNew.Bind(ObjPtr(this)))
        this.FileMenu.Add("New &Window`tCtrl+Shift+N", this.MenuFileNewWindow.Bind(ObjPtr(this)))
        this.FileMenu.Add("&Open`tCtrl+O", this.MenuFileOpen.Bind(ObjPtr(this)))
        this.FileMenu.Add("&Save`tCtrl+S", this.MenuFileSave.Bind(ObjPtr(this)))
        this.FileMenu.Add("Save &As...`t Ctrl+Shift+S", this.MenuFileSaveAs.Bind(ObjPtr(this)))
        this.FileMenu.Add()	; Separator line.
        this.FileMenu.Add("E&xit", this.MenuFileExit.Bind(ObjPtr(this)))

        this.EditMenu := Menu()
        this.EditMenu.Add("&Undo`tCtrl+Z", this.MenuEditUndo.Bind(ObjPtr(this)))
        this.EditMenu.Add()
        this.EditMenu.Add("Cu&t`tCtrl+X", this.MenuEditCut.Bind(ObjPtr(this)))
        this.EditMenu.Add("&Copy`tCtrl+C", this.MenuEditCopy.Bind(ObjPtr(this)))
        this.EditMenu.Add("&Paste`tCtrl+P", this.MenuEditPaste.Bind(ObjPtr(this)))
        this.EditMenu.Add("De&lete`tDel", this.MenuEditDelete.Bind(ObjPtr(this)))
        this.EditMenu.Add()
        ; this.EditMenu.Add("&Find`tCtrl+F", this.MenuEditFind.Bind(ObjPtr(this)))
        ; this.EditMenu.Add("&Find Next`tF3", this.MenuEditReplace.Bind(ObjPtr(this)))
        ; this.EditMenu.Add("Find Pre&vious`tShift+F3", this.MenuEditReplace.Bind(ObjPtr(this)))
        ; this.EditMenu.Add("&Replace`tCtrl+H", this.MenuEditReplace.Bind(ObjPtr(this)))
        ; this.EditMenu.Add("&Go To`tCtrl+G", this.MenuEditGoTo.Bind(ObjPtr(this)))
        ; this.EditMenu.Add()
        ; this.EditMenu.Add("Select &All	Ctrl+A", this.MenuEditSelectAll.Bind(ObjPtr(this)))
        ; this.EditMenu.Add("&Time/Date	F5", this.MenuEditTimeDate.Bind(ObjPtr(this)))
        ; ; Create the menu bar by attaching the submenus to it:
        this.MyMenuBar := MenuBar()
        this.MyMenuBar.Add("&File", this.FileMenu)
        this.MyMenuBar.Add("&Edit", this.EditMenu)

        ; Attach the menu bar to the window:
        this.MenuBar := this.MyMenuBar

        this.SB := this.AddStatusBar(, "")
        this.SB.SetParts(600 - 430, 140, 50, 120, 120)
        this.SB.SetText(" Ln 1, Col 1", 2)
        this.SB.SetText(" 100%", 3)
        this.SB.SetText(" Windows (CRLF)", 4)
        this.SB.SetText(" UTF-8", 5)
        this.OnEvent("Size", "Gui_Size")
        this.OnEvent("DropFiles", "Gui_DropFiles")
        this.Title := Title
        this.Show()
    }

    MainEdit_Change(EditCtrl, Info) {
        if !InStr(this.Title,"*"){
            this.Title := "*" this.Title
        }
        CurrentCol := EditGetCurrentCol(this.MainEdit)
        CurrentLine := EditGetCurrentLine(this.MainEdit)
        this.SB.SetText(" Ln " CurrentLine ",  Col " CurrentCol, 2)
        this.SB.Redraw()
    }

    MenuEditUndo(*) {
        this := ObjFromPtrAddRef(this)
        SendMessage(0x0304, , , this.MainEdit)
    }

    MenuEditCut(*) {
        this := ObjFromPtrAddRef(this)
        SendMessage(0x0300, , , this.MainEdit)
    }
    MenuEditCopy(*) {
        this := ObjFromPtrAddRef(this)
        SendMessage(0x0301, , , this.MainEdit)
    }
    MenuEditPaste(*) {
        this := ObjFromPtrAddRef(this)
        SendMessage(0x0302, , , this.MainEdit)
    }
    MenuEditDelete(*) {
        this := ObjFromPtrAddRef(this)
        SendMessage(0x0303, , , this.MainEdit)
    }
    MenuEditSelectAll(*) {
        this := ObjFromPtrAddRef(this)
        SendMessage(0xB1, 0, StrLen(this.MainEdit.Text), , this.MainEdit)	;EM_SETSEL := 0xB1 ;select text
    }

    MenuEditReplace(*) {
        this := ObjFromPtrAddRef(this)
        gReplace := Gui("+owner" this.Hwnd)

        gReplace.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
        gReplace.Opt("+0x94C80000")
        gReplace.Opt("-Toolwindow")

        gReplace.Add("Text", "x6 y15 w72 h13", "Fi&nd what:")

        ogcEditFindWhat := gReplace.Add("Edit", "x81 y11 w171 h20", "")
        ogcEditFindWhat.OnEvent("Change", gReplace_ReDraw)
        gReplace.Add("Text", "x6 y42 w72 h13", "Re&place with:")
        ogcEditReplaceWith := gReplace.Add("Edit", "x81 y39 w171 h20", "")
        ogcCheckBoxMatchCase := gReplace.Add("Checkbox", "x6 y101 w89 h20", "Match &case")
        ogcCheckBoxWrapAround := gReplace.Add("Checkbox", "x6 y127 w96 h20 Checked", "Wrap ar&ound")
        ogcButtonFindNext := gReplace.Add("Button", "x261 y7 w75 h23 Default", "&Find Next")
        ogcButtonFindNext.OnEvent("Click", gReplace_FindNext)
        ogcButtonReplace := gReplace.Add("Button", "x261 y34 w75 h23", "&Replace")
        ogcButtonReplace.OnEvent("Click", gReplace_Replace)
        ogcButtonReplaceAll := gReplace.Add("Button", "x261 y62 w75 h23", "Replace &All")
        ogcButtonReplaceAll.OnEvent("Click", gReplace_ReplaceAll)
        ogcButtonCancel := gReplace.Add("Button", "x261 y89 w75 h23", "Cancel")
        ogcButtonCancel.OnEvent("Click", gReplace_Close)

        gReplace.Title := "Replace"
        gReplace.OnEvent("Close", gReplace_Close)
        gReplace.OnEvent("Escape", gReplace_Close)
        gReplace_ReDraw(gReplace)

        gReplace.Show("x673 y727 h153 w344")
        Return

        gReplace_ReDraw(*) {
            if (ogcEditFindWhat.Value = "") {
                ogcButtonFindNext.Opt("+Disabled")
                ogcButtonReplace.Opt("+Disabled")
                ogcButtonReplaceAll.Opt("+Disabled")
            } else {
                ogcButtonFindNext.Opt("-Disabled")
                ogcButtonReplace.Opt("-Disabled")
                ogcButtonReplaceAll.Opt("-Disabled")
            }
        }

        gReplace_Find(*) {
            CaseSense := ogcCheckBoxMatchCase.value = 0 ? false : true
            StartPos := EndPos := 0
            DllCall("User32.dll\SendMessage", "Ptr", this.MainEdit.Hwnd, "UInt", 0x00B0, "UIntP", &StartPos, "UIntP", &EndPos, "Ptr")

            FoundPos := ""
            SearchText := this.MainEdit.Text
            FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense, EndPos + 1)
            if (FoundPos = 0 and ogcCheckBoxWrapAround.Value) {
                FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense)
            }

            if (FoundPos != "" and FoundPos != 0) {
                SendMessage(0xB1, FoundPos - 1, FoundPos + StrLen(ogcEditFindWhat.Value) - 1, , this.MainEdit)	;EM_SETSEL := 0xB1 ;deselect text
            } else {
                Return 0
            }
            return 1
        }
        gReplace_FindNext(*) {
            if !gReplace_Find(gReplace) {
                msgResult := MsgBox("Cannot find `"" ogcEditFindWhat.Value "`"", , 4160)
            }
        }

        gReplace_Replace(*) {
            SelectedText := EditGetSelectedText(this.MainEdit)
            ReplacedNumber := 0
            if (ogcEditFindWhat.Value = SelectedText) {
                vText := ogcEditReplaceWith.Value
                DllCall("SendMessage", "UInt", this.MainEdit.Hwnd, "UInt", 0xC2, "UInt", 0, "Str", &vText)
                ReplacedNumber++
            }

            if (!gReplace_Find(gReplace) and !ReplacedNumber) {
                msgResult := MsgBox("Cannot find `"" ogcEditFindWhat.Value "`"", , 4160)
            }
        }

        gReplace_ReplaceAll(*) {
            if InStr(this.MainEdit.Text, ogcEditFindWhat.Value) {
                this.MainEdit.Text := StrReplace(this.MainEdit.Text, ogcEditFindWhat.Value, ogcEditReplaceWith.Value)
            }
        }

        gReplace_Close(*) {
            gReplace.Destroy()
        }
    }

    MenuEditTimeDate(*) {
        this := ObjFromPtrAddRef(this)
        EditPaste(A_Hour ":" A_Min " " A_DD "/" A_MM "/" A_YYYY, this.MainEdit)
    }

    MenuEditFind(*) {
        this := ObjFromPtrAddRef(this)
        gFind := Gui("+owner" This.Hwnd)

        gFind.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
        gFind.Opt("+0x94C80000")
        gFind.Opt("-Toolwindow")
        gFind.Add("Text", "x6 y13 w63 h13", "Fi&nd what:")
        ogcEditFindWhat := gFind.Add("Edit", "x71 y11 w192 h20", "")
        ogcEditFindWhat.OnEvent("Change", gFind_FindWhat)
        ogcCheckBoxMatchCase := gFind.Add("Checkbox", "x6 y68 w96 h20", "Match &case")
        ogcCheckBoxWrapAround := gFind.Add("Checkbox", "x6 y94 w96 h20 Checked", "W&rap around")
        gFind.Add("GroupBox", "x161 y42 w102 h46", "Direction")
        ogcRadioDirection := gFind.Add("Radio", "x167 y62 w38 h20", "&Up")
        gFind.Add("Radio", "x207 y62 w53 h20 checked", "&Down")
        ogcButtonFindNext := gFind.Add("Button", "x273 y8 w75 h23 Default", "&Find Next")
        ogcButtonFindNext.OnEvent("Click", gFind_ButtonFindNext)
        ogcButtonCancel := gFind.Add("Button", "x273 y37 w75 h23", "Cancel")
        ogcButtonCancel.OnEvent("Click", gFind_Close)
        gFind.Title := "Find"
        gFind.OnEvent("Close", gFind_Close)
        gFind.OnEvent("Escape", gFind_Close)
        if (ogcEditFindWhat.Value = "") {
            ogcButtonFindNext.Opt("+Disabled")
        } else {
            ogcButtonFindNext.Opt("-Disabled")
        }
        gFind.Show("x569 y672 h120 w354")
        Return

        gFind_Close(*) {
            gFind.Destroy()
        }
        gFind_ButtonFindNext(*) {

            CaseSense := ogcCheckBoxMatchCase.value = 0 ? false : true
            StartPos := EndPos := 0
            DllCall("User32.dll\SendMessage", "Ptr", this.MainEdit.HWND, "UInt", 0x00B0, "UIntP", &StartPos, "UIntP", &EndPos, "Ptr")
            if (ogcRadioDirection.Value) {
                Occurence := -1
            } else {
                Occurence := +1
            }

            FoundPos := ""
            SearchText := this.MainEdit.Text
            if (!ogcRadioDirection.Value) {
                FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense, EndPos + 1)
                if (FoundPos = 0 and ogcCheckBoxWrapAround.Value) {
                    FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense)
                }
            } else {
                if (StartPos = 0 and ogcCheckBoxWrapAround.Value) {
                    FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense, -1, -1)
                } else {
                    FoundPos := InStr(SearchText, ogcEditFindWhat.Value, CaseSense, StartPos, -1)
                }
            }

            if (FoundPos != "" and FoundPos != 0) {
                SendMessage(0xB1, FoundPos - 1, FoundPos + StrLen(ogcEditFindWhat.Value) - 1, , this.MainEdit)	;EM_SETSEL := 0xB1 ;select text
            } else {
                msgResult := MsgBox("Cannot find `"" ogcEditFindWhat.Value "`"", , 4160)
            }

        }
        gFind_FindWhat(*) {
            if (ogcEditFindWhat.Value = "") {
                ogcButtonFindNext.Opt("+Disabled")
            } else {
                ogcButtonFindNext.Opt("-Disabled")
            }
        }
    }

    MenuEditGoTo(*) {
        this := ObjFromPtrAddRef(this)
        gGoTo := Gui("+owner" this.Hwnd)
        gGoTo.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
        gGoTo.Opt("+0x94C80000")
        gGoTo.Opt("-Toolwindow")
        gGoTo.Add("Text", "x11 y11 w173 h13", "&Line number:")
        ogcEditLineNumber := gGoTo.Add("Edit", "x11 y29 w227 h23 +Number", )
        ogcButtonGoTO := gGoTo.Add("Button", "x83 y63 w75 h23 Default", "Go To")
        ogcButtonGoTO.OnEvent("Click", gFind_ButtonGoTo)
        ogcButtonCancel := gGoTo.Add("Button", "x164 y63 w75 h23", "Cancel")
        ogcButtonCancel.OnEvent("Click", gGoTo_Close)

        gGoTo.Title := "Go To Line"
        gGoTo.Show("x157 y466 h98 w249")
        Return

        gGoTo_Close(*) {
            gGoTo.Destroy()
        }
        gFind_ButtonGoTo(*) {
            LineCount := EditGetLineCount(this.MainEdit)
            if (ogcEditLineNumber.value > LineCount) {
                MsgBox("The line number is beyond the total number of lines", , 4096)
            } else {
                if (ogcEditLineNumber.value = 1) {
                    FoundPos := 0
                } else {
                    FoundPos := InStr(this.MainEdit.Text, "`n", , , ogcEditLineNumber.value - 1)
                }
                SendMessage(0xB1, FoundPos, FoundPos, , this.MainEdit)

                gGoTo.Destroy()
            }
        }
    }

    MenuFileSave(*) {
        try {
            this := ObjFromPtrAddRef(this)
        }
        catch{
            this := this
        }
            if (this.FilePath = "") {
            This.Opt("+OwnDialogs")	; Force the user to dismiss the FileSelect dialog before returning to the main window.
            this.FilePath := FileSelect("S16", "*.txt", "Save As", "Text Documents (*.txt)")
            if this.FilePath = ""	; No file selected.
                return
        }
        try
        {
            if FileExist(this.FilePath)
                FileDelete(this.FilePath)
            FileAppend(This.MainEdit.Value, this.FilePath)	; Save the contents to the file.
        } catch
        {
            MsgBox("The attempt to overwrite '" this.FilePath "' failed.")
            return
        }
        return
    }

    MenuFileSaveAs(*) {
        this := ObjFromPtrAddRef(this)

        this.Opt("+OwnDialogs")	; Force the user to dismiss the FileSelect dialog before returning to the main window.
        this.FilePath := FileSelect("S16", "*.txt", "Save As", "Text Documents (*.txt)")
        if this.FilePath = ""	; No file selected.
            return

        try
        {
            if FileExist(this.FilePath)
                FileDelete(this.FilePath)
            FileAppend(This.MainEdit.Value, this.FilePath)	; Save the contents to the file.
        } catch
        {
            MsgBox("The attempt to overwrite '" this.FilePath "' failed.")
            return
        }
        return
    }
    
    MenuFileNew(*) {
        this := ObjFromPtrAddRef(this)
        this.Gui_CheckChanges("New")

        ; this.FileMenu.Disable("4&")	; Gray out &Save.
    }

    MenuFileNewWindow(*){
        CustomGui("Untitled - AhkPad")
    }
    
    MenuFileOpen(*) {
        this := ObjFromPtrAddRef(this)
        this.Opt("+OwnDialogs")	; Force the user to dismiss the FileSelect dialog before returning to the main window.
        SelectedFileName := FileSelect(3, , "Open File", "Text Documents (*.txt)")
        if SelectedFileName = ""	; No file selected.
            return
        This.Gui_OpenFile(SelectedFileName)
    }

    MenuFileExit(*) {	; User chose "Exit" from the File menu.
        this := ObjFromPtrAddRef(this)
        this.Gui_CheckChanges("Destroy")
    }

    Gui_OpenFile(FilePath){
        SplitPath(FilePath, &OutFileName)
        this.FilePath := FilePath
        this.MainEdit.Value := FileRead(FilePath)
        this.Title := OutFileName " - AhkPad"
    }

    Gui_CheckChanges(Mode := "") {
        if InStr(this.Title, "*") {
            ; Close the file, ask for save
            gSC := Gui("+owner" this.Hwnd)
            gSC.OnEvent("Close", gSC_Close)
            gSC.OnEvent("Escape", gSC_Close)
            gSC.Opt("+Toolwindow -MaximizeBox -MinimizeBox")
            gSC.Opt("+0x94C80000")
            gSC.Opt("-Toolwindow")
            SaveDescrip := IsSet(CurrentFileName) ? " " CurrentFileName "?`n" : "Untitled?`n"
            gSC.SetFont("s12 cPurple W200")
            gSC.AddText("x0 y0 w354 BackgroundWhite Wrap ", "`n  Do you want to save changes to " SaveDescrip "")
            gSC.SetFont("s10 cBlack W400")

            ogcButtonSave := gSC.AddButton("Default x92 y+10 w72 h23", "&Save")
            
            if (Mode = "Destroy") {
                ogcButtonSave.OnEvent("Click", gSC_SaveClose)
            } else {
                ogcButtonSave.OnEvent("Click", gSC_SaveNew)
            }
            ogcButtonDontSave := gSC.Add("Button", "x+6 yp w92 h23", "&Don't Save")
            if (Mode = "Destroy") {
                ogcButtonDontSave.OnEvent("Click", gSC_Destroy)
            }
            else{
                ogcButtonDontSave.OnEvent("Click", gSC_DontSaveAndNew)
            }
            ogcButtonCancel := gSC.Add("Button", "x+6 yp w72 h23", "&Cancel")
            ogcButtonCancel.OnEvent("Click", gSC_Cancel)

            gSC.Title := "Notepad"
            this.Opt("+Disabled")
            gSC.Show(" w350")
            Return
        }
        else if (Mode = "Destroy") {
            this.Destroy()
        }

        gSC_Cancel(*) {
            This.Opt("-Disabled")
            gSC.Destroy()
            Exit
        }
        gSC_Destroy(*){
            This.Destroy()
        }
        gSC_SaveClose(*) {
            gSC.Hide()
            this.Opt("-Disabled")
            if this.MenuFileSave(ObjPtr(this)) {
                this.Destroy()
            }
            gSC.Destroy()
        }
        gSC_SaveNew(*) {
            this.Opt("-Disabled")
            if this.MenuFileSave(ObjPtr(this)) {
                    this.Title := "Untitled - AhkPad"
                    this.MainEdit.Value := ""	; Clear the Edit control.
            }
            gSC.Destroy()
        }
        gSC_DontSaveAndNew(*) {
            this.Opt("-Disabled")
            this.Title := "Untitled - AhkPad"
            this.MainEdit.Value := ""	; Clear the Edit control.
            gSC.Destroy()
        }
        gSC_Close(*){
            this.Opt("-Disabled")	; Re-enable the main window (must be done prior to the next step).
            gSC.Destroy()	; Destroy the about box.
        }
    }

    Gui_DropFiles(Ctrl, FileArray, * ) {	; Support drag & drop.
        if !InStr(this.Title, "*") {
            ; Close the file, ask for save
        }
        this.Gui_OpenFile(FileArray[1])
    }

    Gui_Size(MinMax, Width, Height) {
        if (MinMax = -1)	; The window has been minimized. No action needed.
            return
        ; Otherwise, the window has been resized or maximized. Resize the Edit control to match.
        this.MainEdit.Move(, , Width + 4, Height + 4 - this.SB.Visible * 23)
        this.SB.SetParts(Width - 430, 140, 50, 120, 120)
        this.SB.Redraw()
    }

    SB_Redraw(*) {
        this.SB.Redraw()
    }

}