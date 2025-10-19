; ABOUT: AHK v2 script to create a GUI with a three-column ListView.

;https://www.google.com/search?q=ahk2+3+column+listbox+examples&sca_esv=6fbc5b85f7533cfa&rlz=1C1CHBF_enUS1066US1066&ei=igzXaJm9JrHTkPIPobO_sAc&ved=0ahUKEwiZqvmYtvePAxWxKUQIHaHZD3YQ4dUDCBE&uact=5&oq=ahk2+3+column+listbox+examples&gs_lp=Egxnd3Mtd2l6LXNlcnAiHmFoazIgMyBjb2x1bW4gbGlzdGJveCBleGFtcGxlczIFECEYoAEyBRAhGKABMgUQIRigATIFECEYoAFIvEJQ-gVYkkFwAXgCkAEAmAGZAaAB-RuqAQQ0NC4zuAEDyAEA-AEBmAIgoALIEcICChAAGLADGNYEGEfCAgQQABhHwgIHEAAYqQYYHsICBRAAGO8FwgIIEAAYgAQYogTCAgYQABgWGB7CAgUQABiABMICBRAhGKsCwgIHECEYoAEYCpgDAOIDBRIBMSBAiAYBkAYDkgcEMzAuMqAHzdkBsgcEMjguMrgHwRHCBwQ3LjI1yAcq&sclient=gws-wiz-serp

#SingleInstance Force
#Requires AutoHotkey v2.0


; Define the GUI window title.
guiTitle := "3-Column ListView Example"

; Create a new GUI window object.
MyGui := Gui(, guiTitle)

; Create the ListView control. The options define its size and behavior.
; The column titles are provided as an array.
; 'r10' sets the height to 10 rows.
; 'w400' sets the width to 400 pixels.
; 'Grid' adds grid lines to make the columns clearer.
LV := MyGui.Add("ListView", "r10 w400 Grid", ["Name", "Favorite Color", "Age"])

; Example data to populate the ListView.
; This could also be read from a file or another source.
data := [
    ["Alice", "Blue", 30],
    ["Bob", "Green", 25],
    ["Charlie", "Red", 35],
    ["Diana", "Purple", 28],
    ["Eve", "Yellow", 42],
]

; Loop through the array and add each row to the ListView.
for each, row in data {
    LV.Add("", row*) ; The splat operator `row*` unpacks the array elements into parameters.
}

; Auto-size all columns based on their content.
LV.ModifyCol(1, "AutoHdr") ; Auto-size column 1 based on its content and header.
LV.ModifyCol(2, "AutoHdr") ; Auto-size column 2.
LV.ModifyCol(3, "AutoHdr") ; Auto-size column 3.

; Set up a handler for a double-click event on the ListView.
; This is an optional step to demonstrate user interaction.
LV.OnEvent("DoubleClick", OnLV_DoubleClick)

; Show the GUI window.
MyGui.Show()

; --- Functions (or methods in a class) used by the script ---

; This function is called when a row in the ListView is double-clicked.
OnLV_DoubleClick(LV, RowNum) {
    ; Get the text from the columns of the selected row.
    name := LV.GetText(RowNum, 1)
    color := LV.GetText(RowNum, 2)
    age := LV.GetText(RowNum, 3)

    ; Display a message box with the selected data.
    MsgBox("You double-clicked on row: " . RowNum . "`n"
        . "Name: " . name . "`n"
        . "Favorite Color: " . color . "`n"
        . "Age: " . age)
}
