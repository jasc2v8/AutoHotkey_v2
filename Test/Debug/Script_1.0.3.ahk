#Requires AutoHotkey v2.0
; Version 1.0.2

ExtractVariablesToListView()

ExtractVariablesToListView() {
    ; Example Script Content
    ScriptContent := "
    (
    ItemName := 'Widget'
    item_count := 10
    global UserMode := 1
    local temp_var = 50
    const_factor := 1.5
    FilePath := A_MyDocuments . '\Settings.ini'
    )"

    if (ScriptContent = "")
    return

    ; Create GUI
    MyGui := Gui("+Resize", "Variable & Value Extractor")
    LV := MyGui.Add("ListView", "r15 w400", ["Variable Name", "Assigned Value"])
    
    ; Updated Pattern:
    ; Group 1: The variable name
    ; Group 2: The value (captured until end of line or start of a comment)
    VarPattern := "m)^[ \t]*(?:global|local|static)?[ \t]*(\w+)[ \t]*(?::=|=)(?!=)[ \t]*(.*)"
    
    Pos := 1
    FoundVars := Map()

    while (Pos := RegExMatch(ScriptContent, VarPattern, &Match, Pos)) {
        VarName := Match[1]
        VarValue := Trim(Match[2])
        
        ; Strip trailing comments from the value capture if they exist
        if (SubStr(VarValue, 1, 1) != ";") {
            VarValue := RegExReplace(VarValue, "\s+;.*$", "")
        }

        ; Check if we've already logged this variable to avoid duplicates
        if !FoundVars.Has(VarName) {
            FoundVars[VarName] := true
            LV.Add(, VarName, VarValue)
        }
        
        Pos += Match.Len
    }

    LV.ModifyCol(1, "AutoHdr")
    LV.ModifyCol(2, "AutoHdr")
    MyGui.Show()
}