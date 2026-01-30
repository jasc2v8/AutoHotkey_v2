; TITLE  :  RegExExtractor v1.0.0.10
; SOURCE :  jasc2v8 and Gemini
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Test RegEx Match Patterns
; USAGE  :  
; NOTES  :

/*
 * RegEx Extractor
 * Version: 1.0.0.10
 * Requirements: AutoHotkey v2.0+
 */

#Requires AutoHotkey v2.0

; Initialize the GUI
MainGui := Gui("+Resize", "RegEx Extractor v1.0.0.10")
MainGui.SetFont("s10", "Segoe UI")

MainGui.Add("Text",, "Input Text (Haystack):")
InputEdit := MainGui.Add("Edit", "w500 r8 vHaystack", "The current script version is v1.0.0.1 and the old one was v1.0.0.0.")

MainGui.Add("Text",, "RegEx Pattern (Needle):")
; Standard PCRE pattern for version extraction
PatternEdit := MainGui.Add("Edit", "w500 vPattern", "v(\d+\.\d+\.\d+\.\d+)")

; Buttons row
ExtractBtn := MainGui.Add("Button", "Default w90", "Extract")
ExtractBtn.OnEvent("Click", ProcessExtraction)

CopyBtn := MainGui.Add("Button", "x+10 w110", "Copy Results")
CopyBtn.OnEvent("Click", (*) => A_Clipboard := ResultEdit.Value)

ClearBtn := MainGui.Add("Button", "x+10 w80", "Clear")
ClearBtn.OnEvent("Click", (*) => ResultEdit.Value := "")

CancelBtn := MainGui.Add("Button", "x+10 w80", "Cancel")
CancelBtn.OnEvent("Click", (*) => ExitApp())

MainGui.Add("Text", "xm", "Results:")
ResultEdit := MainGui.Add("Edit", "w500 r10 ReadOnly vResult")

MainGui.Show()

ProcessExtraction(*) {
    Saved := MainGui.Submit(false)
    Haystack := Saved.Haystack
    Pattern := Saved.Pattern
    
    ; Requirements: if and return on separate lines
    if (Haystack = "")
        return
    
    if (Pattern = "")
        return

    OutputText := ""
    CurrentPos := 1
    
    try {
        ; Use &Match to automatically create a match object in v2
        while (RegExMatch(Haystack, Pattern, &Match, CurrentPos)) {
            OutputText .= "Full Match: " Match[0] "`n"
            
            ; Loop through capturing groups
            Loop Match.Count {
                OutputText .= "  Group " A_Index ": " Match[A_Index] "`n"
            }
            
            OutputText .= "--------------------`n"
            
            ; Increment position to find the next match
            CurrentPos := Match.Pos + Match.Len
            
            ; Prevent infinite loops if the pattern matches an empty string
            if (Match.Len = 0)
                CurrentPos += 1
        }
    } catch Error as err {
        ResultEdit.Value := "RegEx Error: " err.Message "`nOffset: " err.Extra
        return
    }
    
    if (OutputText = "")
        ResultEdit.Value := "No matches found."
    else
        ResultEdit.Value := OutputText
}

GuiClose(*) {
    ExitApp()
}