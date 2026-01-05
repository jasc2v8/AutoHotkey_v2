; TITLE: ConsoleLog v.0
/*
  TODO:
*/
#Requires AutoHotkey 2.0+

ConsoleLog(text) {
    stdout := FileOpen("*", "w")
    stdout.WriteLine(text)
    stdout.Read(0) ; Flush the buffer
}

;ConsoleLog("Task started...")
;ConsoleLog("Processing data...")
;ConsoleLog("Done!")
