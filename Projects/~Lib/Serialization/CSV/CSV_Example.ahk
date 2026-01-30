
#Requires AutoHotkey 2+

#Include CSV.ahk

; Example Usage
RawData := 'Name,Location,Note`n"John ""The Hammer"" Doe",New York,Likes Pizza`nJane Smith,London,"Enjoys `nnewlines"'

; 1. Convert String to 2D Array
CSVArray := CSV.FromString(RawData)

; Accessing data: [Row][Column]
MsgBox("First Name: " . CSVArray[2][1]) ; John "The Hammer" Doe

; 2. Convert 2D Array back to String
NewCSVString := CSV.ToString(CSVArray)
MsgBox(NewCSVString)
