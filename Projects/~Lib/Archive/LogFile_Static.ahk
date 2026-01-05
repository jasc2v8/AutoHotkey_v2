/**
 * A static class for logging messages to a file.
 * It uses static variables to store configuration and state.
 */
class Logger {

    /**
     * @var string The path to the log file. This is a static class variable.
     */
    static LogFile := ''

    /**
     * Initializes the logger with a log file path.
     * This method must be called once before logging can begin.
     * @param filePath The full path to the log file.
     */
    static Init(filePath) {
        this.LogFile := filePath
        ; Create an empty log file to start, overwriting if it exists.
        FileDelete this.LogFile
        FileAppend 'Logger Initialized: ' . A_YYYYMMDDHH24MISS . '`n', this.LogFile
    }
    
    /**
     * Appends a message to the log file.
     * @param message The message to log.
     */
    static Log(message) {
        ; Check if the logger has been initialized.
        if (this.LogFile = '') {
            MsgBox 'Error: Logger has not been initialized. Please call Logger.Init() first.', 'Logger Error'
            return
        }
        
        FileAppend A_YYYYMMDDHH24MISS . ' - ' . message . '`n', this.LogFile
    }

    /**
     * Gets the full path of the current log file.
     * @return The path to the log file.
     */
    static GetLogFilePath() {
        return this.LogFile
    }
}


; --- Example Usage ---

; Step 1: Initialize the logger with a file path.
; We use a file in the user's temporary folder for this example.
logPath := A_Temp '\MyLog.txt'
Logger.Init(logPath)

MsgBox 'Logger initialized. Log file is at: ' . Logger.GetLogFilePath()

; Step 2: Log some messages.
Logger.Log('The script has started.')
Logger.Log('Performing a critical operation.')

; Demonstrate logging an error message.
Logger.Log('ERROR: An unexpected event occurred.')

; The messages will be appended to the MyLog.txt file.
; You can open the file to view the content.
Run('notepad.exe ' . Logger.GetLogFilePath())
