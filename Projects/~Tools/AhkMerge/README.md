# AhkMerge



##### Overview



This tool has two main functions:



1\. Merges an AHK script with all of the #Include files in the script.

    a. Optionally excludes all unused functions from the #Include files.

    b. Optionally excludes Comment and/or Headings.



2\. Combines multiple scripts into one.

    a. Combines entire scripts.

    b. Doesn't process #Include files.



Buttons:



    \[Browse]    Select the main AutoHotkey script (.ahk).



    \[Merge]     Merges the selected script with its #Include files.

                \[ ] Exclude Comments.

                \[ ] Exclude Headers.

                \[ ] Exclude Unused Classes and Functions.



    \[Combine]   Opens a FileSelect Dialog to select file(s) to combine.

                \[ ] Checkboxes are ignored.



    \[Help]      Shows this help text.



    \[Cancel]    Closes the application.



##### Merge Example



1. MainScript.ahk contains #Include <LibFile>.
2. <LibFile> contains MyFunction1(), MyFunction2(), MyFunction3()
3. MainScript.ahk contains reference var := MyFunction2(param)
4. MainScript\_Merged.ahk includes only MyFunction2(), excluding the others.
