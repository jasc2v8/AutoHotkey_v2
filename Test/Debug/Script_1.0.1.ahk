#Requires AutoHotkey v2.0
; Version 1.0.1

ExtractVariablesToListView()

ExtractVariablesToListView() {
    ; Example Script Content (In a real scenario, you might use FileRead)
    ScriptContent := "
    (
    ItemName := 'Widget'
    item_count := 10
    global UserMode := 1
    local temp_var = 50
    const_factor := 1.5
    )"

    if (ScriptContent = "")
    return

    ; Create GUI
    MyGui := Gui("+Resize", "Variable Extractor")
    LV := MyGui.Add("ListView", "r15 w300", ["Variable Name", "Line Found"])
    
    ; RegEx pattern to find potential variable assignments
    ; This looks for words followed by := or = (excluding ==)
    VarPattern := "m)^[ \t]*(?:global|local|static)?[ \t]*(\w+)[ \t]*(?::=|=)(?!=)"
    
    Pos := 1
    FoundVars := Map() ; Use a map to track unique variables

    while (Pos := RegExMatch(ScriptContent, VarPattern, &Match, Pos)) {
        VarName := Match[1]
        
        ; Only add if not already in our map to keep the list clean
        if !FoundVars.Has(VarName) {
            FoundVars[VarName] := true
            LV.Add(, VarName, "Detected")
        }
        
        Pos += Match.Len
    }

    LV.ModifyCol(1, "AutoHdr")
    MyGui.Show()
}