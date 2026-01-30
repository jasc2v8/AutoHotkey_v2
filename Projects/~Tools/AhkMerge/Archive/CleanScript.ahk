/*
 * Script: CleanScript
 * Version: 1.0.0.5
 * Description: Removes all comments (block and inline) and extra whitespace.
 */

CleanAHKScript(ScriptContent) {
    if (ScriptContent = "")
        return ""

    ; Remove block comments /* ... */
    ; The 's' option allows dot to match newlines
    ScriptContent := RegExReplace(ScriptContent, "s)/\*.*?\*/", "")

    ; Remove inline comments and full-line comments
    ; Matches a space/tab followed by a semicolon, or a semicolon at start of line
    ScriptContent := RegExReplace(ScriptContent, "m)(^\s*;.*|(?<=\s);.*)", "")

    ; Trim trailing whitespace from each line
    ScriptContent := RegExReplace(ScriptContent, "m)[ \t]+$", "")

    ; Remove extra blank lines (replaces 3+ newlines with 2)
    ScriptContent := RegExReplace(ScriptContent, "\R{3,}", "`r`n`r`n")

    ; Final trim for start and end of file
    return Trim(ScriptContent, "`r`n`t ")
}

; Example usage with your specific 'return' formatting rule
SampleCode := "
(
/* Old Header Info 
*/
global MyVar := 1 ; Initialize variable

if (MinMax = -1)
    return

; More comments here
MsgBox('Done')
)"

MsgBox(CleanAHKScript(SampleCode))