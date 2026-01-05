
#Requires AutoHotkey v2.0

; --- Configuration ---
words_in_paragraph := 60  ; How many words to generate in the paragraph
words_in_sentence := 8    ; Average number of words per sentence (for random pauses)
source_text := "lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum"

; --- Main Hotkey ---
; Press Ctrl + Shift + L to generate and paste the text
; ^!q::
; {
    ; lorem_text := GenerateLoremIpsum(words_in_paragraph, words_in_sentence, source_text)

    ; MsgBox lorem_text

    ; Send the generated text using the current clipboard content restoration method
    ; A_Clipboard := lorem_text
    ; Send '^v' ; Paste the generated text
    ; A_Clipboard := '' ; Clear the clipboard (optional)
;}

; --- Lorem Ipsum Generation Function ---
GenerateLoremIpsum(wordCount:=60, avgSentenceWords:=8, sourceText:="")
{
    default_text := "lorem ipsum dolor sit amet consectetur adipiscing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum"

    sourceText := (sourceText = "") ? "lorem ipsum dolor sit amet" : default_text

    ; Split the source text into an array of individual words
    word_list := StrSplit(sourceText, ' ')
    list_length := word_list.Length
    output_text := ''
    current_sentence_word_count := 0

    Loop wordCount
    {
        ; 1. Pick a random word index
        N := Random(1, list_length)

        current_word := word_list[N]

        ; 2. Determine if we should end the sentence here
        ; Randomly select a number between -3 and +3 around the average
        current_sentence_word_count := Random(avgSentenceWords - 3, avgSentenceWords + 3)
        sentence_break_chance := Random(1,10)

        if (current_sentence_word_count >= sentence_break_chance)
        {
            ; End of sentence: Add punctuation and capitalize the next word
            
            ; Capitalize the first letter of the *current* word before adding punctuation
            ; (This makes the punctuation follow a capital word, simulating the end of a previous sentence)
            current_word := StrUpper(SubStr(current_word, 1, 1)) . SubStr(current_word, 2)
            
            punctuation_type := Random(1, 3)
            if (punctuation_type == 1) ; 50% chance for a period
                current_word .= '.'
            else if (punctuation_type == 2) ; 25% chance for a comma (within sentence)
                current_word .= ','
            else ; 25% chance for an exclamation or question mark
                current_word .= (Random(1, 2) == 1 ? '!' : '?')

            output_text .= current_word ' '
            
            ; Reset sentence counter for the next word (which will be capitalized)
            current_sentence_word_count := 0
        }
        else
        {
            ; Normal word: just append it
            current_sentence_word_count++
            
            ; Capitalize the very first word of the paragraph/sentence
            if (current_sentence_word_count == 1 || InStr(output_text, '.') == StrLen(output_text))
                current_word := StrUpper(SubStr(current_word, 1, 1)) . SubStr(current_word, 2)
            
            output_text .= current_word ' '
        }
    }

    ; Ensure the paragraph ends with a period
    if (SubStr(output_text, -1) != '.')
        output_text := Trim(output_text) . '.'

    return output_text
}