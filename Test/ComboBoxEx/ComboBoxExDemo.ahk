#Requires AutoHotkey v2.0
; Create an image list for the ComboBoxEx control
Icons := [74, 77, 80, 82, 94, 95, 101, 102, 103]
HIL := IL_Create(9, 9)
For Icon In Icons
   IL_Add(HIL, "Imageres.dll", Icon)
; Create the Gui and the Control
Items := ["One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"]
Win := Gui( , "ComboBoxEx")
Win.MarginX := 20
Win.MarginY := 20
Win.OnEvent("Close", WinCLose)
Win.AddText("xm cNavy", "ComboBoxEx - Combo:")
CBE1 := ComboBoxEx(Win, "Combo", "xm y+5 r10")
For Index, Item In Items
   CBE1.Add(Item, Index)
Win.AddText("xm cNavy", "ComboBoxEx - DDL:")
CBE2 := ComboBoxEx(Win, "DDL",   "xm y+5 r10")
For Index, Item In Items
   CBE2.Add(Item, Index)
Win.Show()

MsgBox(CBE1.ClassNN " - " CBE1.Style)

WinClose(*) => ExitApp()

^+T:: {
   MsgBox(CBE1.Value " - " CBE1.Text)
}

; ======================================================================================================================
; Class to handle ComboBoxEx controls.
; -> https://learn.microsoft.com/en-us/windows/win32/controls/comboboxex-control-reference
; For methods and properties see GuiControl Object
; -> https://www.autohotkey.com/docs/v2/lib/GuiControl.htm
; ======================================================================================================================
Class ComboBoxEx {
   ; ===================================================================================================================
   ; Creates a new ComboBoxEx control.
   ; Parameters:
   ;     Win      -  Gui object
   ;     Style    -  "Combo" (ComboBox) or "DDL" (DropDownList) as string
   ;     XYWH     -  pos and size options as string
   ; Returns a new instance of class ComboBoxEx.
   ; ===================================================================================================================
   __New(Win, Style, XYWH := "") {
      ; CBEM_GETEDITCONTROL = 0x0407, CBEM_SETIMAGELIST = 0x0402
      Static CBS := {Combo: 0x0002, DDL: 0x0003}
      Static WS := 0x40000000 + 0x10000000 ; WS_CHILD + WS_VISIBLE
      Local Styles, CBB
      Styles := WS | CBS.%Style%
      CBB := Win.AddCustom("ClassComboBoxEx32 " . XYWH . " " . Styles)
      (Style = "Combo") && ControlSetStyle("+0x1000", SendMessage(0x0407, 0, 0, CBB))
      SendMessage(0x0402, 0, HIL, CBB)
      This.DefineProp("Ctrl", {Get: (*) => CBB})
      Local Edit := (Style = "DDL" ? 0 : SendMessage(0x0407, 0, 0, This))
      This.DefineProp("Edit", {Get: (*) => Edit})
      This.DefineProp("Style", {Get: (*) => Style})
   }
   ; ===================================================================================================================
   ; Methods
   ; ===================================================================================================================
   Add(Item, Icon := 0) {
      Local CBEI := Buffer(A_PtrSize * 7, 0)
      Local Mask := (Icon < 1) ? 0x01 : 0x07
      Icon-- ; 1-based -> 0-based
      NumPut("UPtr", Mask, "Ptr", -1, "Ptr", StrPtr(Item), "Int", 0, "Int", Icon, "Int", Icon, CBEI)
      SendMessage(0x040B, 0, CBEI, This)
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Choose(Index) => ControlChooseIndex(Index, This)
   ; -------------------------------------------------------------------------------------------------------------------
   ; CB_RESETCONTENT = 0x014B
   Delete(Index?) => (IsSet(Index) ? ControlDeleteItem(Index, This) : SendMessage(0x014B, 0, 0, This))
   ; -------------------------------------------------------------------------------------------------------------------
   Focus() => This.Ctrl.Focus()
   ; -------------------------------------------------------------------------------------------------------------------
   GetPos(&X?, &Y?, &Width?, &Height?) => This.Ctrl.GetPos(&X?, &Y?, &Width?, &Height?)
   ; -------------------------------------------------------------------------------------------------------------------
   Move(X?, Y?, Width?, Height?) => This.Ctrl.Move(X?, Y?, Width?, Height?)
   ; -------------------------------------------------------------------------------------------------------------------
   OnCommand(NotifyCode, Callback, AddRemove?) => This.Ctrl.OnCommand(NotifyCode, Callback, AddRemove?)
   ; -------------------------------------------------------------------------------------------------------------------
   OnNotify(NotifyCode, Callback, AddRemove?) => This.Ctrl.OnNotify(NotifyCode, Callback, AddRemove?)
   ; -------------------------------------------------------------------------------------------------------------------
   ; OnEvent(*)   not supported!!!
   ; -------------------------------------------------------------------------------------------------------------------
   ; Opt(*)       not supported!!!
   ; -------------------------------------------------------------------------------------------------------------------
   Redraw() => This.Ctrl.Redraw()
   ; -------------------------------------------------------------------------------------------------------------------
   SetFont(Options?, FontName?) => This.Ctrl.SetFont(Options?, FontName?)
   ; ===================================================================================================================
   ; Properties
   ; ===================================================================================================================
   ClassNN => This.Ctrl.ClassNN
   ; -------------------------------------------------------------------------------------------------------------------
   Enabled {
      Get => This.Ctrl.Enabled
      Set => This.Ctrl.Enabled := Value
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Focused => This.Ctrl.Focused
   ; -------------------------------------------------------------------------------------------------------------------
   Gui => This.Ctrl.Gui
   ; -------------------------------------------------------------------------------------------------------------------
   Hwnd => This.Ctrl.Hwnd
   ; -------------------------------------------------------------------------------------------------------------------
   ; Name         not supported!!!
   ; -------------------------------------------------------------------------------------------------------------------
   Type => "Custom.ComboBoxEx_" . This.Style
   ; -------------------------------------------------------------------------------------------------------------------
   Value {
      Get => ControlGetIndex(This)
      Set {
         Throw Error("The Value property of ComboBoxEx controls is readonly!", -1)
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Text {
      Get {
         Local Item := ControlGetIndex(This)
         If Item = 0 {
            If This.Edit
               Return ControlGetText(This.Edit)
            Else
               Return ""
         }
         Else
            Return ControlGetChoice(This)
      }
      Set {
         Throw Error("The Text property of ComboBoxEx controls is readonly!", -1)
      }
   }
   ; -------------------------------------------------------------------------------------------------------------------
   Visible {
      Get => This.Ctrl.Visible
      Set => This.Ctrl.Visible := Value
   }
   ; ===================================================================================================================
}