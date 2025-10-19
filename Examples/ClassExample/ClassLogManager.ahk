#Requires AutoHotkey v2.0

; --- Standalone Function (Outside the class) ---
; A general-purpose function that doesn't rely on any object instance.
FormatTimeStamp(timestamp) {
    ; Formats the timestamp for logging
    ;return Format('{:yyyy-MM-dd HH:mm:ss}', timestamp)
    return Format('{: HH:mm:ss}', timestamp)
}

; -----------------------------------------------
; --- LogManager Class (The Class Definition) ---
; -----------------------------------------------
class LogManager {
    ; Instance variable to hold the log file path
    Filename := ''
    TimeStamp := ''

    PrivateVar := 'This is a Private Variable'

    static PublicVar := 'This is a Public Variable'

    ; 1. Constructor Method: __New
    ; This runs when a new object is created (e.g., LogManager('C:\log.txt')).
    __New(filename) {
        this.Filename := filename
        ; Optional: Write a header on creation
        this.Log('--- Session Started ---')

        var := this.GetTimeStamp()
        OutputDebug('TimeStamp: ' var)
    }

    ; 2. Instance Method: Log(message)
    ; This method requires an instance of the class and uses the 'this' keyword
    ; to access the instance variable 'this.Filename'.
    Log(message) {
        Time := FormatTimeStamp(A_Now) ; Call the standalone function
        LogEntry := Time ' | ' message '`n'

        ; Use the built-in FileAppend function to write to the file
        FileAppend(LogEntry, this.Filename)
    }

    ; 3. Static Method: GetDefaultPath()
    ; This method belongs to the class itself, not a specific instance.
    ; It can be called without creating a LogManager object (e.g., LogManager.GetDefaultPath()).
    static GetDefaultPath() {
        return A_ScriptDir '\default_app.log'
    }

    GetTimeStamp(){
        return FormatTime(A_Now, 'HH:mm:ss')
    }
}

; -----------------------------
; --- Usage Demonstration ---
; -----------------------------

; 1. Use the Static Method directly from the Class
DefaultLog := LogManager.GetDefaultPath()
OutputDebug('Default log path: ' DefaultLog)

PublicVar := LogManager.PublicVar
OutputDebug('PublicVar: ' PublicVar)

; 2. Create an Instance of the Class (calls __New) 
Logger := LogManager(DefaultLog)

; 3. Call the Instance Method
Logger.Log('The application logger instance was created.')
Logger.Log('Starting main process loop...')

; 4. Another way to use the standalone function
CurrentFormattedTime := FormatTimeStamp(A_Now)
Logger.Log('Current formatted time using function: ' CurrentFormattedTime)

; End
OutputDebug('Logging complete. Check ' DefaultLog)
Exit