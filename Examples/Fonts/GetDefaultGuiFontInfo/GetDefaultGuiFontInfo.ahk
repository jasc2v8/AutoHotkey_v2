;ABOUT: 

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

Escape::ExitApp()

NL := "`n"

font := GeDefaultFontInfo()

text :=  "Name    : " Format('{:12}', font.Name) . NL .
         "Size    : " Format('{:12}', font.Size) NL .
         "Weight  : " Format('{:12}', font.Weight) NL .
         "IsItalic: " Format('{:12}', font.IsItalic)

g := Gui(,"Default Gui Font")
g.AddEdit("w240 -VScroll", "This is what the default font looks like.")
g.SetFont("s11", "Consolas")
g.AddEdit("xm w240 -VScroll", text)
g.SetFont()
g.AddButton("w75 Default", "OK").OnEvent("Click", (*) => ExitApp())
g.Show
ControlFocus("OK", g)

GeDefaultFontInfo(&Name:="", &Size:=0, &Weight:=0, &IsItalic:=0) {

   ; SystemParametersInfo constant for retrieving the metrics associated with the nonclient area of nonminimized windows
   static SPI_GETNONCLIENTMETRICS := 0x0029
   static A_IsUnicode := true     ; Ahk v2 is Unicode only
   static NCM_Size        := 40 + 5*(A_IsUnicode ? 92 : 60)   ; Size of NONCLIENTMETRICS structure (not including iPaddedBorderWidth)
   static MsgFont_Offset  := 40 + 4*(A_IsUnicode ? 92 : 60)   ; Offset for lfMessageFont in NONCLIENTMETRICS structure
   static Size_Offset     := 0    ; Offset for cbSize in NONCLIENTMETRICS structure
   static Height_Offset   := 0    ; Offset for lfHeight in LOGFONT structure
   static Weight_Offset   := 16   ; Offset for lfWeight in LOGFONT structure
   static Italic_Offset   := 20   ; Offset for lfItalic in LOGFONT structure
   static FaceName_Offset := 28   ; Offset for lfFaceName in LOGFONT structure
   static FACESIZE        := 32   ; Size of lfFaceName array in LOGFONT structure (Max chars in font name string)
 
   NCM := Buffer(NCM_Size, 0)       ; Set the size of the NCM structure and initialize it
   
   NumPut("UInt", NCM_Size, NCM)   ; Set the cbSize element of the NCM structure

   ; Get the system parameters and store them in the NONCLIENTMETRICS structure (NCM)
   if !DllCall("SystemParametersInfo"            ; If the SystemParametersInfo function returns a NULL value ...
             , "UInt", SPI_GETNONCLIENTMETRICS
             , "UInt", NCM_Size
             , "Ptr", NCM.Ptr
             , "UInt", 0)                        ; Don't update the user profile
      Return false                               ; Return false

   Name   := StrGet(NCM.Ptr + MsgFont_Offset + FaceName_Offset, FACESIZE, "UTF-16") ; Get the font name
   Height := NumGet(NCM.Ptr + MsgFont_Offset + Height_Offset, "Int")                ; Get the font height
   Size   := DllCall("MulDiv", "Int", -Height, "Int", 72, "Int", A_ScreenDPI)       ; Convert the font height to the font size in points

   ; Reference: http://stackoverflow.com/questions/2944149/converting-logfont-height-to-font-size-in-points
   Weight   := NumGet(NCM.Ptr + MsgFont_Offset + Weight_Offset, "Int")             ; Get the font weight (400 is normal and 700 is bold)
   IsItalic := NumGet(NCM.Ptr + MsgFont_Offset + Italic_Offset, "UChar")           ; Get the italic state of the font

   ;Return true
   return { Name: Name, Size: Size, Weight: Weight , IsItalic: IsItalic  }
}
