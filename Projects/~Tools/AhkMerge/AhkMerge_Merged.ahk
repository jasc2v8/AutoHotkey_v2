;====================================================================================================
;D:\Software\DEV\Work\AHK2\Projects\AhkMerge\AhkMerge_Merged.ahk
;====================================================================================================
;C:\Users\Jim\Documents\AutoHotkey\Lib\String_Functions.ahk
;C:\Users\Jim\Documents\AutoHotkey\Lib\Debug.ahk
;C:\Users\Jim\Documents\AutoHotkey\Lib\String.ahk
;C:\Users\Jim\Documents\AutoHotkey\Lib\IniLite.ahk
;D:\Software\DEV\Work\AHK2\Projects\AhkMerge\AhkMerge.ahk
;====================================================================================================
;====================================================================================================
;C:\Users\Jim\Documents\AutoHotkey\Lib\String_Functions.ahk
;====================================================================================================
SubStrExtract(Text, StartChar, EndChar)
{
    StartPos := InStr(Text, StartChar) + 1
    EndPos := InStr(Text, EndChar)
    Length := EndPos - StartPos
    return SubStr(Text, StartPos, Length)
}
IsEmpty(str) {
    return str = ''
}
;====================================================================================================
;C:\Users\Jim\Documents\AutoHotkey\Lib\Debug.ahk
;====================================================================================================
class Debug
{
    static MBox(Text, Title:="", Options:="")
    {
        return MsgBox(Text, Title, Options)
    }
    
    static WriteLine(Text)
    {
        OutputDebug(Text)
    }

    static FileWrite(Text, Filename:="", Overwrite:=True)
    {
        Filename := (Filename) ? Filename : A_ScriptDir.JoinPath("Debug.txt")
        If (Overwrite AND FileExist(Filename))
            FileDelete(Filename)
        FileAppend(Text "`n", Filename)
    }

    static FileWriteLine(Text, Filename:="", Overwrite:=True)
    {
        Debug.FileWrite(Text "`n", Filename, Overwrite)
    }

    /*
        MyArray := ["item1", "item2", "item3"]
        MyLine := "The quick brown fox.`r`n"
        MyCSV := "apple, banana, cherry"
        MyMap := Map("Key1", "Value1", "Key2", "Value2")
        MyObj := {KeyA: "ValueA", KeyB: "ValueB", KeyC: "ValueC"}
    */

    ;-------------------------------------------------------------------------------
    ; Purpose: Lists the values of an Array, Map, Object, or String in a MsgBox.
    ; Returns: The Button pressed in the MsgBox.
    ; Params : Enclose:="%", or Enclose:="[]", etc.
    static ListVar(MyObject, Title:="", Options:="", Enclose:="") {

    if InStr("Array, Map, Object, String", Type(MyObject)) = 0 {
        MsgBox "Value not enumerable.`n`nType: " Type(MyObject), "Error"
        return
    }

    Title := Title.IsEmpty() ? "Type: " Type(MyObject) : Title

    Text := ''

    objType := Type(MyObject)

    switch objType {
        case "Array":
            for index, value in MyObject {
                newvalue :=  (Enclose.Length >= 2) ? Enclose[1] . value . Enclose[2] : Enclose . value . Enclose
                Text .= index ": " newvalue "`n`n"
            }
        case "Map" :
            for key, value in MyObject {
                newvalue:=(Enclose.Length = 1) ?  value : Enclose[1] . value . Enclose[2]
                Text .= key ": " newvalue "`n`n"
            }
        case "Object" :
            for key, value in MyObject.OwnProps() {
                newvalue:=(Enclose.Length = 1) ?  value : Enclose[1] . value . Enclose[2]
                Text .= key ": " newvalue "`n`n"
            }
        case "String" :
            ; Line String
            if MyObject.EndsWith("`r`n") {
                ItemArray := StrSplit(MyObject, "`r`n")
                for index, value in ItemArray {
                    if (value) {
                        value := value.Trim()
                        newvalue:=(Enclose.Length = 1) ?  value : Enclose[1] . value . Enclose[2]
                        Text .= index ": " newvalue "`n"
                    }
                }
            } else if MyObject.Contains(",") {
                ; CSV String
                ItemArray := StrSplit(MyObject, ",")
                if ItemArray.Length >= 1 {
                    for index, value in ItemArray {
                        if (value) {
                            value := value.Trim()
                            newvalue :=  (Enclose.Length >= 2) ? Enclose[1] . value . Enclose[2] : Enclose . value . Enclose
                            Text .= index ": " newvalue "`n"
                        }
                    }  
                }
            } else {
                Text := MyObject
            }
        }
    return MsgBox(Text, Title, Options)
    }

    ; Purpose: Displays the script's variables: their names and current contents.
    static ListVariables() {
        ListVars
    }
}
;====================================================================================================
;C:\Users\Jim\Documents\AutoHotkey\Lib\String.ahk
;====================================================================================================
	Class String2 {

	static __New() {
		; Add String2 methods and properties into String object
		__ObjDefineProp := Object.Prototype.DefineProp
		for __String2_Prop in String2.OwnProps()
			if SubStr(__String2_Prop, 1, 2) != "__"
				__ObjDefineProp(String.Prototype, __String2_Prop, String2.GetOwnPropDesc(__String2_Prop))
		__ObjDefineProp(String.Prototype, "__Item", {get:(args*)=>String2.__Item[args*]})
		__ObjDefineProp(String.Prototype, "__Enum", {call:String2.__Enum})
	}

	static __Item[args*] {
		get {
			if args.length = 2
				return SubStr(args[1], args[2], 1)
			else {
				len := StrLen(args[1])
				if args[2] < 0
					args[2] := len+args[2]+1
				if args[3] < 0
					args[3] := len+args[3]+1
				if args[3] >= args[2]
					return SubStr(args[1], args[2], args[3]-args[2]+1)
				else
					return SubStr(args[1], args[3], args[2]-args[3]+1).Reverse()
			}
		}
	}

	static __Enum(varCount) {
		pos := 0, len := StrLen(this)
		EnumElements(&char) {
			char := StrGet(StrPtr(this) + 2*pos, 1)
			return ++pos <= len
		}
		
		EnumIndexAndElements(&index, &char) {
			char := StrGet(StrPtr(this) + 2*pos, 1), index := ++pos
			return pos <= len
		}

		return varCount = 1 ? EnumElements : EnumIndexAndElements
	}
	; Native functions implemented as methods for the String object
	static Length    	  => StrLen(this)
	static WLength        => (RegExReplace(this, "s).", "", &i), i)
	static ULength        => StrLen(RegExReplace(this, "s)((?>\P{M}(\p{M}|\x{200D}))+\P{M})|\X", "_"))
	static IsDigit		  => IsDigit(this)
	static IsXDigit		  => IsXDigit(this)
	static IsAlpha		  => IsAlpha(this)
	static IsUpper		  => IsUpper(this)
	static IsLower		  => IsLower(this)
	static IsAlnum		  => IsAlnum(this)
	static IsSpace		  => IsSpace(this)
	static IsTime		  => IsTime(this)
	static ToUpper()      => StrUpper(this)
	static ToLower()      => StrLower(this)
	static ToTitle()      => StrTitle(this)
	static Split(args*)   => StrSplit(this, args*)
	static Replace(args*) => StrReplace(this, args*)
	static Trim(args*)    => Trim(this, args*)
	static LTrim(args*)   => LTrim(this, args*)
	static RTrim(args*)   => RTrim(this, args*)
	static Compare(args*) => StrCompare(this, args*)
	static Sort(args*)    => Sort(this, args*)
	static Format(args*)  => Format(this, args*)
	static Find(args*)    => InStr(this, args*)
	static SplitPath() 	  => (SplitPath(this, &a1, &a2, &a3, &a4, &a5), {FileName: a1, Dir: a2, Ext: a3, NameNoExt: a4, Drive: a5})

	static IndexOf(args*) => InStr(this, args*)
	static SplitShortcut() => (FileGetShortcut(this, &a1, &a2, &a3, &a4, &a5, &a6, &a7), {Target: a1, Dir: a2, Args: a3, Description: a4, Icon: a5, IconNum: a6, RunState: a7})
	static IsEmpty()      => StrLen(this) == 0

	/**
	 * Returns the match object
	 * @param needleRegex *String* What pattern to match
	 * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
	 * @returns {Object}
	 */
	static RegExMatch(needleRegex, &match?, startingPos?) => (RegExMatch(this, needleRegex, &match, startingPos?), match)
	/**
	* Returns all RegExMatch results in an array: [RegExMatchInfo1, RegExMatchInfo2, ...]
	* @param needleRegEx *String* The RegEx pattern to search for.
	* @param startingPosition *Integer* If StartingPos is omitted, it defaults to 1 (the beginning of haystack).
	* @returns {Array}
	*/
	static RegExMatchAll(needleRegEx, startingPosition := 1) {
		out := []
		While startingPosition := RegExMatch(this, needleRegEx, &outputVar, startingPosition)
			out.Push(outputVar), startingPosition += outputVar[0] ? StrLen(outputVar[0]) : 1
		return out
	}
	 /**
	  * Uses regex to perform a replacement, returns the changed string
	  * @param needleRegex *String* What pattern to match.
	  * 	This can also be a Array of needles (and replacement a corresponding array of replacement values), 
	  * 	in which case all of the pairs will be searched for and replaced with the corresponding replacement. 
	  * 	replacement should be left empty, outputVarCount will be set to the total number of replacements, limit is the maximum
	  * 	number of replacements for each needle-replacement pair.
	  * @param replacement *String* What to replace that match into
	  * @param outputVarCount *VarRef* Specify a variable with a `&` before it to assign it to the amount of replacements that have occured
	  * @param limit *Integer* The maximum amount of replacements that can happen. Unlimited by default
	  * @param startingPos *Integer* Specify a number to start matching at. By default, starts matching at the beginning of the string
	  * @returns {String} The changed string
	  */
	static RegExReplace(needleRegex, replacement?, &outputVarCount?, limit?, startingPos?) {
		if IsObject(needleRegex) {
			out := this, count := 0
			for i, needle in needleRegex {
				out := RegExReplace(out, needle, IsSet(replacement) ? replacement[i] : unset, &count, limit?, startingPos?)
				if IsSet(outputVarCount)
					outputVarCount += count
			}
			return out
		}
		return RegExReplace(this, needleRegex, replacement?, &outputVarCount, limit?, startingPos?)
	}
	/**
	 * Add character(s) to left side of the input string.
	 * example: "aaa".LPad("+", 5)
	 * output: +++++aaa
	 * @param padding Text you want to add
	 * @param count How many times do you want to repeat adding to the left side.
	 * @returns {String}
	 */
	static LPad(count:=1, padding:=A_Space) {
		str := this
		if (count>0) {
			Loop count
				str := padding str
		}
		return str
	}

	/**
	 * Add character(s) to right side of the input string.
	 * example: "aaa".RPad("+", 5)
	 * output: aaa+++++
	 * @param padding Text you want to add
	 * @param count How many times do you want to repeat adding to the left side.
	 * @returns {String}
	 */
	static RPad(count:=1, padding:=A_Space) {
		str := this
		if (count>0) {
			Loop count
				str := str padding
		}
		return str
	}

	/**
	 * Count the number of occurrences of needle in the string
	 * input: "12234".Count("2")
	 * output: 2
	 * @param needle Text to search for
	 * @param caseSensitive
	 * @returns {Integer}
	 */
	static Count(needle, caseSensitive:=False) {
		StrReplace(this, needle,, caseSensitive, &count)
		return count
	}

	/**
	 * Duplicate the string 'count' times.
	 * input: "abc".Repeat(3)
	 * output: "abcabcabc"
	 * @param count *Integer*
	 * @returns {String}
	 */
	static Repeat(count) => StrReplace(Format("{:" count "}",""), " ", this)

	/**
	 * Reverse the string.
	 * @returns {String}
	 */
	static Reverse() {
		DllCall("msvcrt\_wcsrev", "str", str := this, "CDecl str")
		return str
	}
	static WReverse() {
		str := this, out := "", m := ""
		While str && (m := Chr(Ord(str))) && (out := m . out)
			str := SubStr(str,StrLen(m)+1)
		return out
	}

	/**
	 * Insert the string inside 'insert' into position 'pos'
	 * input: "abc".Insert("d", 2)
	 * output: "adbc"
	 * @param insert The text to insert
	 * @param pos *Integer*
	 * @returns {String}
	 */
	static Insert(insert, pos:=1) {
		Length := StrLen(this)
		((pos > 0)
			? pos2 := pos - 1
			: (pos = 0
				? (pos2 := StrLen(this), Length := 0)
				: pos2 := pos
				)
		)
		output := SubStr(this, 1, pos2) . insert . SubStr(this, pos, Length)
		if (StrLen(output) > StrLen(this) + StrLen(insert))
			((Abs(pos) <= StrLen(this)/2)
				? (output := SubStr(output, 1, pos2 - 1)
					. SubStr(output, pos + 1, StrLen(this))
				)
				: (output := SubStr(output, 1, pos2 - StrLen(insert) - 2)
					. SubStr(output, pos - StrLen(insert), StrLen(this))
				)
			)
		return output
	}

	/**
	 * Replace part of the string with the string in 'overwrite' starting from position 'pos'
	 * input: "aaabbbccc".Overwrite("zzz", 4)
	 * output: "aaazzzccc"
	 * @param overwrite Text to insert.
	 * @param pos The position where to begin overwriting. 0 may be used to overwrite at the very end, -1 will offset 1 from the end, and so on.
	 * @returns {String}
	 */
	static Overwrite(overwrite, pos:=1) {
		if (Abs(pos) > StrLen(this))
			return ""
		else if (pos>0)
			return SubStr(this, 1, pos-1) . overwrite . SubStr(this, pos+StrLen(overwrite))
		else if (pos<0)
			return SubStr(this, 1, pos) . overwrite . SubStr(this " ",(Abs(pos) > StrLen(overwrite) ? pos+StrLen(overwrite) : 0), Abs(pos+StrLen(overwrite)))
		else if (pos=0)
			return this . overwrite
	}

	/**
	 * Delete a range of characters from the specified string.
	 * input: "aaabbbccc".Delete(4, 3)
	 * output: "aaaccc"
	 * @param start The position where to start deleting.
	 * @param length How many characters to delete.
	 * @returns {String}
	 */
	static Delete(start:=1, length:=1) {
		if (Abs(start) > StrLen(this))
			return ""
		if (start>0)
			return SubStr(this, 1, start-1) . SubStr(this, start + length)
		else if (start<=0)
			return SubStr(this " ", 1, start-1) SubStr(this " ", ((start<0) ? start-1+length : 0), -1)
	}

	/**
	 * Wrap the string so each line is never more than a specified length.
	 * input: "Apples are a round fruit, usually red".LineWrap(20, "---")
	 * output: "Apples are a round f
	 *          ---ruit, usually red"
	 * @param column Specify a maximum length per line
	 * @param indentChar Choose a character to indent the following lines with
	 * @returns {String}
	 */
	static LineWrap(column:=56, indentChar:="") {
		CharLength := StrLen(indentChar)
		, columnSpan := column - CharLength
		, Ptr := A_PtrSize ? "Ptr" : "UInt"
		, UnicodeModifier := 2
		, VarSetStrCapacity(&out, (finalLength := (StrLen(this) + (Ceil(StrLen(this) / columnSpan) * (column + CharLength + 1))))*2)
		, A := StrPtr(out)

		Loop parse, this, "`n", "`r" {
			if ((FieldLength := StrLen(ALoopField := A_LoopField)) > column) {
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", column * UnicodeModifier)
				, A += column * UnicodeModifier
				, NumPut("UShort", 10, A)
				, A += UnicodeModifier
				, Pos := column

				While (Pos < FieldLength) {
					if CharLength
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(indentChar), "UInt", CharLength * UnicodeModifier)
						, A += CharLength * UnicodeModifier

					if (Pos + columnSpan > FieldLength)
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", (FieldLength - Pos) * UnicodeModifier)
						, A += (FieldLength - Pos) * UnicodeModifier
						, Pos += FieldLength - Pos
					else
						DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField) + (Pos * UnicodeModifier), "UInt", columnSpan * UnicodeModifier)
						, A += columnSpan * UnicodeModifier
						, Pos += columnSpan

					NumPut("UShort", 10, A)
					, A += UnicodeModifier
				}
			} else
				DllCall("RtlMoveMemory", "Ptr", A, "ptr", StrPtr(ALoopField), "UInt", FieldLength * UnicodeModifier)
				, A += FieldLength * UnicodeModifier
				, NumPut("UShort", 10, A)
				, A += UnicodeModifier
		}
		NumPut("UShort", 0, A)
		VarSetStrCapacity(&out, -1)
		return SubStr(out,1, -1)
	}

	/**
	 * Wrap the string so each line is never more than a specified length.
	 * Unlike LineWrap(), this method takes into account words separated by a space.
	 * input: "Apples are a round fruit, usually red.".WordWrap(20, "---")
	 * output: "Apples are a round
	 *          ---fruit, usually
	 *          ---red."
	 * @param column Specify a maximum length per line
	 * @param indentChar Choose a character to indent the following lines with
	 * @returns {String}
	 */
	static WordWrap(column:=56, indentChar:="") {
		if !IsInteger(column)
			throw TypeError("WordWrap: argument 'column' must be an integer", -1)
		out := ""
		indentLength := StrLen(indentChar)

		Loop parse, this, "`n", "`r" {
			if (StrLen(A_LoopField) > column) {
				pos := 1
				Loop parse, A_LoopField, " "
					if (pos + (LoopLength := StrLen(A_LoopField)) <= column)
						out .= (A_Index = 1 ? "" : " ") A_LoopField
						, pos += LoopLength + 1
					else
						pos := LoopLength + 1 + indentLength
						, out .= "`n" indentChar A_LoopField

				out .= "`n"
			} else
				out .= A_LoopField "`n"
		}
		return SubStr(out, 1, -1)
	}

	/**
	* Insert a line of text at the specified line number.
	* The line you specify is pushed down 1 and your text is inserted at its
	* position. A "line" can be determined by the delimiter parameter. Not
	* necessarily just a `r or `n. But perhaps you want a | as your "line".
	* input: "aaa|ccc|ddd".InsertLine("bbb", 2, "|")
	* output: "aaa|bbb|ccc|ddd"
	* @param insert Text you want to insert.
	* @param line What line number to insert at. Use a 0 or negative to start inserting from the end.
	* @param delim The character which defines a "line".
	* @param exclude The text you want to ignore when defining a line.
	* @returns {String}
	 */
	static InsertLine(insert, line, delim:="`n", exclude:="`r") {
		if StrLen(delim) != 1
			throw ValueError("InsertLine: Delimiter can only be a single character", -1)
		into := this, new := ""
		count := into.Count(delim)+1

		; Create any lines that don't exist yet, if the Line is less than the total line count.
		if (line<0 && Abs(line)>count) {
			Loop Abs(line)-count
				into := delim into
			line:=1
		}
		if (line == 0)
			line:=Count+1
		if (line<0)
			line:=count+line+1
		; Create any lines that don't exist yet. Otherwise the Insert doesn't work.
		if (count<line)
			Loop line-count
				into.=delim

		Loop parse, into, delim, exclude
			new.=((a_index==line) ? insert . delim . A_LoopField . delim : A_LoopField . delim)

		return SubStr(new, 1, -(line > count ? 2 : 1))
	}

	/**
	 * Delete a line of text at the specified line number.
	 * The line you specify is deleted and all lines below it are shifted up.
	 * A "line" can be determined by the delimiter parameter. Not necessarily
	 * just a `r or `n. But perhaps you want a | as your "line".
	 * input: "aaa|bbb|777|ccc".DeleteLine(3, "|")
	 * output: "aaa|bbb|ccc"
	 * @param string Text you want to delete the line from.
	 * @param line What line to delete. You may use -1 for the last line and a negative an offset from the last. -2 would be the second to the last.
	 * @param delim The character which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static DeleteLine(line, delim:="`n", exclude:="`r") {
		if StrLen(delim) != 1
			throw ValueError("DeleteLine: Delimiter can only be a single character", -1)
		new := ""
		; checks to see if we are trying to delete a non-existing line.
		count:=this.Count(delim)+1
		if (abs(line)>Count)
			throw ValueError("DeleteLine: the line number cannot be greater than the number of lines", -1)
		if (line<0)
			line:=count+line+1
		else if (line=0)
			throw ValueError("DeleteLine: line number cannot be 0", -1)

		Loop parse, this, delim, exclude {
			if (a_index==line) {
				Continue
			} else
				(new .= A_LoopField . delim)
		}

		return SubStr(new,1,-1)
	}

	/**
	 * Read the content of the specified line in a string. A "line" can be
	 * determined by the delimiter parameter. Not necessarily just a `r or `n.
	 * But perhaps you want a | as your "line".
	 * input: "aaa|bbb|ccc|ddd|eee|fff".ReadLine(4, "|")
	 * output: "ddd"
	 * @param line What line to read*. "L" = The last line. "R" = A random line. Otherwise specify a number to get that line. You may specify a negative number to get the line starting from the end. -1 is the same as "L", the last. -2 would be the second to the last, and so on.
	 * @param delim The character which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static ReadLine(line, delim:="`n", exclude:="`r") {
		out := "", count:=this.Count(delim)+1

		if (line="R")
			line := Random(1, count)
		else if (line="L")
			line := count
		else if abs(line)>Count
			throw ValueError("ReadLine: the line number cannot be greater than the number of lines", -1)
		else if (line<0)
			line:=count+line+1
		else if (line=0)
			throw ValueError("ReadLine: line number cannot be 0", -1)

		Loop parse, this, delim, exclude {
			if A_Index = line
				return A_LoopField
		}
		throw Error("ReadLine: something went wrong, the line was not found", -1)
	}

	/**
	 * Replace all consecutive occurrences of 'delim' with only one occurrence.
	 * input: "aaa|bbb|||ccc||ddd".RemoveDuplicates("|")
	 * output: "aaa|bbb|ccc|ddd"
	 * @param delim *String*
	 */
	static RemoveDuplicates(delim:="`n") => RegExReplace(this, "(\Q" delim "\E)+", "$1")

	/**
	 * Checks whether the string contains any of the needles provided.
	 * input: "aaa|bbb|ccc|ddd".Contains("eee", "aaa")
	 * output: 1 (although the string doesn't contain "eee", it DOES contain "aaa")
	 * @param needles
	 * @returns {Boolean}
	 */
	static Contains(needles*) {
		for needle in needles
			if InStr(this, needle)
				return 1
		return 0
	}

	/**
	 * Centers a block of text to the longest item in the string.
	 * example: "aaa`na`naaaaaaaa".Center()
	 * output: "aaa
	 *           a
	 *       aaaaaaaa"
	 * @param text The text you would like to center.
	 * @param fill A single character to use as the padding to center text.
	 * @param symFill 0: Just fill in the left half. 1: Fill in both sides.
	 * @param delim The character which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @param width Can be specified to add extra padding to the sides
	 * @returns {String}
	 */
	static Center(fill:=" ", symFill:=0, delim:="`n", exclude:="`r", width?) {
		fill:=SubStr(fill,1,1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField)>longest)
				longest := StrLen(A_LoopField)
		if IsSet(width)
			longest := Max(longest, width)
		Loop parse this, delim, exclude 
		{
			filled:="", len := StrLen(A_LoopField)
			Loop (longest-len)//2
				filled.=fill
			new .= filled A_LoopField ((symFill=1) ? filled (2*StrLen(filled)+len = longest ? "" : fill) : "") "`n"
		}
		return RTrim(new,"`r`n")
	}

	/**
	 * Align a block of text to the right side.
	 * input: "aaa`na`naaaaaaaa".Right()
	 * output: "     aaa
	 *                 a
	 *          aaaaaaaa"
	 * @param fill A single character to use as to push the text to the right.
	 * @param delim The character which defines a "line".
	 * @param exclude The text you want to ignore when defining a line.
	 * @returns {String}
	 */
	static Right(fill:=" ", delim:="`n", exclude:="`r") {
		fill:=SubStr(fill,1,1), longest := 0, new := ""
		Loop parse, this, delim, exclude
			if (StrLen(A_LoopField)>longest)
				longest:=StrLen(A_LoopField)
		Loop parse, this, delim, exclude {
			filled:=""
			Loop Abs(longest-StrLen(A_LoopField))
				filled.=fill
			new.= filled A_LoopField "`n"
		}
		return RTrim(new,"`r`n")
	}

	/**
	 * Join a list of strings together to form a string separated by delimiter this was called with.
	 * input: "|".Concat("111", "222", "333", "abc")
	 * output: "111|222|333|abc"
	 * @param words A list of strings separated by a comma.
	 * @returns {String}
	 */
	static Concat(words*) {
		delim := this, s := ""
		for v in words
			s .= v . delim
		return SubStr(s,1,-StrLen(this))
	}

	; |=======================================================================|

	/**
	 * Extracts a substring between two delimiter characters.
	 * input : "something".Extract("e", "i")
	 * output: "th"
	 * @returns  {String}
	 */
	static ExtractBetween(StartChar, EndChar) {
		StartPos := InStr(this, StartChar) + 1
		EndPos := InStr(this, EndChar)
		Length := EndPos - StartPos
		return SubStr(this, StartPos, Length)
	}

	/**
	 * Joins words together with a delimiter.
	 * input : "Result: ".Join(",", "a", "b", "c")
	 * output: "th"
	 * @returns  {String}
	 */
	static Join(Delimiter, Words*) {
		s := this . Delimiter
		for w in Words
			s .= w . Delimiter
		return SubStr(s, 1, StrLen(s)-1)
	}

	/**
	 * Returns a substring between two delimiter characters.
	 * input : "something".Extract("e", "i")
	 * output: "th"
	 * @returns  {String}
	 */
	static JoinPath(Words*) {
		s := this.Join("\", Words*)

		While (InStr(s, "\\") != 0)
			s := StrReplace(s, "\\", "\")
		return s
	}
	/**
	 * Returns a substring between two delimiter characters.
	 * input : "something".Extract("e", "i")
	 * output: "th"
	 * @returns  {String}
	 */
	static LastIndexOf(Needle, CaseSense:=false) {
    	return InStr(this, Needle, CaseSense, -Needle.Length)
	}

	/**
	 * Returns a substring enclosed with two delimiter characters.
	 * Example: "something".Enclose('"') +> "something"
	 * Example: "something".Enclose("[]") +> [something]
	 * @returns  {String}
	 */
	static Enclose(ends) {
		return (ends.Length >= 2) ? ends[1] . this . ends[2] : ends . this . ends
	}

	/**
	 * Returns a substring of a string ending with a parameter.
	 * input : "something".EndsWith("ing", True)
	 * output: True
	 * @returns  {Boolean}
	 */
	static EndsWith(Needle, CaseSense := false) {
    	return StrCompare(SubStr(this, -Needle.Length, Needle.Length), Needle, CaseSense) = 0
	}

	/**
	 * Returns a RegExMatch for a given pattern.
	 * input : "#Include <MyLib>".Match("#Include\s*<([^>]+)>")
	 * output: <MyLib>
	 * @returns  {String}
	 */
	static Match(Needle) {
 	   RegExMatch(this, Needle, &Match)
    	return IsObject(Match) ? Match.1 : ""
	}

	/**
	 * Returns a substring of a string starting with a parameter.
	 * input : "something".StartsWith("some", True)
	 * output: True
	 * @returns  {Boolean}
	 */
	static StartsWith(Needle, CaseSense := false) {
    	return StrCompare(SubStr(this, 1, Needle.Length), Needle, CaseSense) = 0
	}
}
;====================================================================================================
;C:\Users\Jim\Documents\AutoHotkey\Lib\IniLite.ahk
;====================================================================================================
class IniLite
{
    IniPath := ''

    __New(IniFilePath:="")
    {
        if IniFilePath = "" {
            IniFilePath := A_ScriptFullPath.SplitPath().NameNoExt ".ini"
        } else {
            SplitPath(IniFilePath,, &IniDir)
            if !DirExist(IniDir)
            DirCreate(IniDir)
        }

        if !FileExist(IniFilePath)
            FileAppend("[Settings]`r`n", IniFilePath)
            ;FileAppend("INI_PATH=" IniFilePath "`r`n", IniFilePath)
            
        this.IniPath := IniFilePath

        ;MsgBox this.IniPath, "IniLite"
	}

    Read(section, key) {

        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath, section, key)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    ReadSection(section) {
        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath, section)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    ReadSectionNames() {
        try {
            if FileExist(this.IniPath) {
                return IniRead(this.IniPath)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

	ReadSettings(key) {
        try {
            if FileExist(this.IniPath) {
        		return IniRead(this.IniPath, "Settings", key)
            } else {
                return ; default is ''
            }
        } catch Error as e {
            return ; default is ''
        }
	}

    Write(section, key, value) {
		try {
			if FileExist(this.IniPath) {
				IniWrite(value, this.IniPath, section, key)
				return true
			} else {
				return false
			}
		} catch Error as e {
			return false
		}
	}
	
	WriteSettings(key, value) {
                try {
            if FileExist(this.IniPath) {
                return IniWrite(value, this.IniPath, "Settings", key )
            } else {
                return false
            }
        } catch Error as e {
            return false
        }
	}
}
;====================================================================================================
;D:\Software\DEV\Work\AHK2\Projects\AhkMerge\AhkMerge.ahk
;====================================================================================================
;ABOUT: AhkMerge v0.0.0.0

;TODO:
;   
;
;

;#Requires AutoHotkey v2.0+

#SingleInstance Force
#NoTrayIcon

;#Include <String_Functions>

;#Include <Debug>

;#Include <String>

;#Include <IniLite>

;DEBUG
Escape::ExitApp()
if FileExist("DEBUG_MainScriptText.txt")
    FileDelete("DEBUG_MainScriptText.txt")
if FileExist("DEBUG_ReadInclude.txt")
    FileDelete("DEBUG_ReadInclude.txt")
if FileExist("DEBUG_FunctionsCSV.txt")
    FileDelete("DEBUG_FunctionsCSV.txt")

; #region Globals

global AhkPath          := "C:\Program Files\AutoHotkey"
global MainScriptPath    := A_ScriptFullPath
global IncludedFiles := ""
global MergedScript := ""

INI_PATH := A_Temp.JoinPath("AhkApps", A_ScriptName.Replace(".ahk", ".ini"))
global INI := IniLite(INI_PATH)

; #region Initialize INI

SelectedFile := INI.ReadSettings("SelectedFile")

if SelectedFile.IsEmpty() OR Not FileExist(SelectedFile) {
    SelectedFile := MainScriptPath
}

; #region Create Gui

myGui := Gui()
myGui.Title := "AhkMerge v1.0"
MyGui.BackColor := "4682B4" ; Steel Blue

MyGui.SetFont("S12 cWhite", "Segouie UI")
myGui.AddText("xm ym", "Select a file:")

MyGui.SetFont("S10 cDefault", "Consolas")
ScriptEdit := myGui.AddEdit("xm y+5 w600", SelectedFile)

MyGui.SetFont("S9 cWhite", "Segoe UI")
myGui.AddButton("x+8 yp w75", "Browse").OnEvent("Click", SelectFile)

MyGui.SetFont("S10 cWhite", "Segoe UI")
MyCheckBoxExcludeComments := 
    myGui.AddCheckbox("xm w350 Section", "Exclude Comments")
MyCheckBoxExcludeHeaders :=
    myGui.AddCheckbox("xm w350", "Exclude Headers")
MyCheckBoxExcludeUnusedClassesAndFunctions :=
    myGui.AddCheckbox("xm w350 Checked", "Exclude Unused Classes and Functions")

MyGui.SetFont("S09", "Segoe UI")
myGui.AddButton("x540 ys w75 Section Default", "Merge").OnEvent("Click", ButtonMerge_Click)
myGui.AddButton("yp w75", "Help").OnEvent("Click", (*) => ButtonHelp_Click())
myGui.AddButton("xs w75", "Combine").OnEvent("Click", (*) => ButtonCombine_Click())
myGui.AddButton("yp w75", "Cancel").OnEvent("Click", (*) => ExitApp())
myGui.AddText("xm w1 h1 Hidden", "Hidden Spacer")

MyCheckBoxExcludeHeaders.OnEvent("Click", CheckBox_Change)

myGui.Show()

ControlFocus("Cancel", MyGui)

;OK DEBUG Test Str_Functions
;var := "The rain in [Spain] stays mainly in the plain."
; MsgBox IsEmpty(var), "Should be 0=False"
;newvar := SubStrExtract(var, '[', ']'), "[Spain]"
;MsgBox SubStrExtract(var, '[', ']'), "[Spain]"

; text := "test " ';' " comment"
; text := "test comment"
; result := Trim(StrSplit(text, ";")[1])
; Debug.MBox result

; #region Functions

ButtonCombine_Click() {

    selectedFiles := FileSelect(Multi:="M3", A_ScriptDir, "Select File(s) to Combine.","Ahk Script Files (*.ahk)")

    if selectedFiles.Length >0 {
        text := "1: " A_ScriptName . "`n`n"
        for k, v in selectedFiles
             text .= k+1 ": " v.SplitPath().nameNoExt "`n`n"
        r := MsgBox("Files to Combine:`n`n" text, "ButtonCombine_Click", "YesNo Icon?")
        if (r="No")
            return

        textBuffer := ""
        for file in selectedFiles
            textBuffer .= FileRead(file)

        outFile :=FileSelect(OverWrite:=16,,"Save As...","Ahk Script Files (*.ahk)")
        if outFile.IsEmpty()
            return

        if NOT outFile.EndsWith(".ahk")
            outFile .= ".ahk"

        FileAppend(textBuffer, outFile)        

    }
}

CheckBox_Change(Ctrl, Info) {
    if MyCheckBoxExcludeHeaders.Value
        MyCheckBoxExcludeComments.Value := true
    else
        MyCheckBoxExcludeComments.Value := false
}

SelectFile(Ctrl, Info) {
    selectedFile := FileSelect(, ScriptEdit.Text,,"Ahk Script Files (*.ahk)")

    if NOT selectedFile.IsEmpty() {
        ScriptEdit.Text := selectedFile
        INI.WriteSettings("SelectedFile", selectedFile.Trim())
    } else {
        SoundBeep
    }
}

ButtonMerge_Click(Ctrl, Info) {

    SelectedFile := ScriptEdit.Text.Trim()

    ; If user copied as path, then paste (includes double quotes)
    if SelectedFile.Contains('"') {
        SelectedFile := SelectedFile.Replace('"', '')
        ScriptEdit.Text := SelectedFile
    }

    ; if valide, update settings
    if FileExist(SelectedFile) {
        INI.WriteSettings("SelectedFile", SelectedFile)
    } else {
        SoundBeep
        return
    }

    ;DEBUG
    if FileExist("FunctionsCSV.txt")
        FileDelete("FunctionsCSV.txt")

    ; Merge the include files
    MergedScript := Merge.Includes(SelectedFile)

;Debug.FileWrite(MergedScript, , true)  ; Default is .\Debug.txt

    outFile := SelectedFile.SplitPath().nameNoExt "_Merged.ahk"
    if FileExist(outfile)
        FileDelete(outfile)
    FileAppend(MergedScript, outfile)

;Debug.MBox(outFile)

    ;DEBUG
    Run("notepad " outfile)

    ;MsgBox("Done!", "Status", "icon?")

    outFile := FileSelect(PromptOverwrite:=16, ScriptEdit.Text.Replace(".ahk", "_Merged.ahk"))

    if outFile.IsEmpty()
        return

    FileDelete(outFile)
    FileAppend(MergedScript, outFile)

}

ButtonHelp_Click() {
    helpText := "
(
__________________________________________________________________

                                    AhkMerge
__________________________________________________________________

This tool has two main functions:

1. ButtonMerge_Click an AHK script with all of the #Include files in the script.
    a. Optionally excludes all unused functions from the #Include files.
    b. Optionally excludes Comment and/or Headings.

2. Combines multiple scripts into one.
    a. Combines entire scripts.
    b. Doesn't process #Include files.

Buttons:

    [Browse]    Select the main AutoHotkey script (.ahk).

    [Merge]     ButtonMerge_Click the selected script with its #Include files.
                        [ ] Exclude Comments.
                        [ ] Exclude Headers.
                        [ ] Exclude Unused Classes and Functions.

    [Combine]   Opens a FileSelect Dialog to select file(s) to combine.
                        [ ] Checkboxes are ignored.

    [Help]      Shows this help text.

    [Cancel]    Closes the application.

)"
    MsgBox(helpText, "Help")
}

class Merge {

    static IncludedFiles := ""
    static MergedScript := ""
    static dividerLine := ";" "=".Repeat(100)

    ; array or csv or map?
    ; Merge files, optionally comment out all #Includes
    static Files(ScriptFilesArray, CommentOutIncludes := True) {
        this.MergedScriptFiles := ""
        return this.MergedScriptFiles
    }

    ; Merge files, optionally comment out all #Includes
    static Includes(ScriptFile) {

        if !FileExist(ScriptFile)
            return
            
        this.MainScriptFile := ScriptFile
        ;this.MainScriptText := this._ReadInclude(ScriptFile)
        this.MainScriptText := FileRead(ScriptFile)

        Debug.FileWrite(this.MainScriptText, "DEBUG_MainScriptText.txt", True)

        ; Initialize variables used in the Recursive Function
        this.IncludedFiles := ""
        this.MergedScript := ""

        ; Recursively get all #Include files in the script file and their includes
        this.IncludedFiles := this._GetIncludes(ScriptFile).RTrim(",")

        Debug.FileWrite(this.IncludedFiles, "DEBUG_IncludedFiles.txt", True)

        ; Add a pretty header
        buffer := ""

        buffer .= this._GetHeader(ScriptFile.Replace(".ahk", "_Merged.ahk"))
       
        ; Add all of the #Include files to the Header
        split := StrSplit(this.IncludedFiles, ",")
        for file in split            
            buffer .= ";" file . "`n"
        buffer .=  ";" ScriptFile "`n"

        buffer .= this.dividerLine . "`n"

        if MyCheckBoxExcludeHeaders.Value
            buffer := ""

        this.MergedScript .= buffer

        ;Debug.MBox this.MergedScript

        ; Add all of the #Include files to the MergedScript
        this.MergedScript .= this._MergeIncludes(ScriptFile, this.IncludedFiles)

        ;Debug.MBox this.MergedScript

        ; Add the script to the MergedScript
        this.MergedScript .= this._GetHeader(ScriptFile)

        ; With or without headers, comment, and unused functions?
        this.MergedScript .= this._ReadInclude(ScriptFile)

        ;Remove multiple blank lines
        CleanScript := RegExReplace(this.MergedScript, "\R{3,}", "`n`n")

        ;Remove blank lines from the end of the script (will leave one blank line at the end)
        CleanScript := RegExReplace(CleanScript, "\R+$", "")

        return CleanScript
    }

    static _AppendLine(Line) {
        this.MergedScript .= Line . "`n"
    }

    static _MergeIncludes(ScriptFile, IncludedFiles) {

        buffer := ""

        split := StrSplit(IncludedFiles, ",")

        for includeFile in split {

            buffer .= this._GetHeader(includeFile)

;            ExcludeUnused :=MyCheckBoxExcludeUnusedClassesAndFunctions.Value

            if MyCheckBoxExcludeUnusedClassesAndFunctions.Value {

                functionsCSV := ScanLibScript(includeFile)
;functionsCSV := GetFunctions(includeFile)

                ;Debug.ListVar(functionsCSV,,,'[]')
                Debug.FileWriteLine(FunctionsCSV, "DEBUG_FunctionsCSV.txt", False)

                ; Read the function from the Include file, if its in the ScriptFile
                ; Else return ""
                Loop Parse FunctionsCSV, "`n", "`r`n" {
                    ;TODO: Choose one:
                     FunctionCSVLine := A_LoopField.Trim()
                     buffer .= this._ReadFunction(ScriptFile, FunctionCSVLine)
                    ;buffer .= this._ReadFunction(ScriptFile, A_LoopField)
                }

            } else {

                Debug.FileWrite(this._ReadInclude(includeFile),"DEBUG_ReadInclude.txt", False)

                ; Merge the entire Include file
                buffer .= this._ReadInclude(includeFile)
             }

        }

        return buffer

    }

    static _GetHeader(ScriptFile) {

        header := this.dividerLine . "`n"
        header .= ";" ScriptFile . "`n"
        header .= this.dividerLine . "`n"

        if MyCheckBoxExcludeHeaders.Value
            header := ""

        return header
    }
    
    static _ReadInclude(ScriptFile) {

        if ScriptFile.IsEmpty()
            return

        ScriptText := FileRead(ScriptFile)

        ;ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

        IgnoreToEnd := False

        InCommentBlock := False

        textBuffer := ""

        Loop Parse ScriptText, "`n", "`r`n"{

            if IgnoreToEnd
                continue

            line        := A_LoopField
            lineTrim    := A_LoopField.Trim()

            if lineTrim.StartsWith("/*")
                InCommentBlock := true

            if lineTrim.StartsWith("*/") {
                InCommentBlock := false
                continue
            }

            if InCommentBlock
                continue

            ; Avoid multiple #Requires
            if lineTrim.StartsWith("#Requires AutoHotkey")
                line := ";" line "`n"

            ; Avoid multiple #Include of the same file
            if lineTrim.StartsWith("#Include") {
                line := ";" line "`n"
            }

            ; Exclude test functions at bottom of script
            if lineTrim.StartsWith("If (A_LineFile == A_ScriptFullPath)") {
                IgnoreToEnd := True
                continue
            }

            ; if CheckBox Exclude Comments is checked
            if (lineTrim.StartsWith(";") AND MyCheckBoxExcludeComments.Value)
                continue

            ; if CheckBox Exclude Comments is checked, remove inline comment
            if MyCheckBoxExcludeComments.Value {
                static needle := A_Space . ";"
                if lineTrim.Contains(needle)
                    line := StrSplit(line, needle)[1].Trim()
            }

            textBuffer .= line "`n"
        }
        return textBuffer
    }

    static _GetIncludes(ScriptFile) {

        if ScriptFile.IsEmpty()
            return

        ScriptText := FileRead(ScriptFile)

        ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

        Loop ScriptTextArray.Length {

            line := ScriptTextArray[A_Index]

            if line.StartsWith("#Include") {

                includeFile := this._FindInLibrary(line)

                if (NOT includeFile.IsEmpty()) AND (NOT this.IncludedFiles.Contains(includeFile)) {
                    this.IncludedFiles .= includeFile ","
                    this._GetIncludes(includeFile)
                }
            }
        }

        ;Remove multiple blank lines
        ;CleanScript := RegExReplace(this.MergedScript, "\R{3,}", "`n`n")

        ;Remove blank lines from the end of the script (will leave one blank line at the end)
        ;CleanScript := RegExReplace(CleanScript, "\R+$", "")

        return this.IncludedFiles
    }

    static _ReadFunction(ScriptFile, IncludeLine) {

        ;Debug.MBox "[" FunctionsCSV "]", "ReadFunction"

        split := IncludeLine.Split(",")

        if split.Length < 4 {
            return ""
        }
    
        ; ok Debug.ListVar split

        functionName := split[1].Trim()
        includeFile := split[2].Trim()
        lineNumber := split[3].Trim()
        lineCount := split[4].Trim()

        ; Debug.WriteLine("ScriptFile: " ScriptFile "`n" .
        ;     'includeFile: ' includeFile  "`n" .
        ;     'function: ' functionName  "`n" .
        ;     'lineNumber: ' lineNumber "`n" . 
        ;     'lineCount: ' lineCount)

        ; search for String in #Include <String> works, but;
        ; should search for #Include ... String because it could be ./Lib/String.ahk etc.
        ;StartsWith := (functionName.Compare("#Include")=0) ? includeFile.SplitPath().nameNoExt : ""
        if (functionName.Compare("#Include")=0) {
            StartsWith := functionName
            functionName := includeFile.SplitPath().nameNoExt
        } else {
            StartsWith := ""
        }
        

        if NOT this._FindIn(this.MainScriptText, StartsWith, functionName)
            return

        ScriptText := FileRead(includeFile)

        ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

        functionText := ""

        Loop ScriptTextArray.Length {

            if A_Index != lineNumber
                continue

            ;Debug.MBox A_Index ", " lineNumber

            index := A_Index

            Loop lineCount {
                functionText .= ScriptTextArray[index] . "`n"
                index++
                if index >= ScriptTextArray.Length
                    break
            }

            break
        }

        ;Debug.WriteLine('functionText: ' functionText)

        return functionText            ;Debug.MBox "[" line "]" "`n`n" "[" split[1] "]" "`n`n" "[" split[2] "]" "`n`n" "[" split[3] "]" "`n`n" "[" split[4] "]", "ReadFunction"
        
    }

    static _FindIn(ScriptText, StartsWith, FunctionName) {
        ; Search the entire file including comments

        found := false

        ;InCommentBlock := false
        ;debugCount := 0

        Loop Parse ScriptText, "`n", "`r`n" {

            ;debugCount++

            line := A_LoopField.Trim()

            ;if line.IsEmpty() OR line.StartsWith(";")
            ;    continue

            ; if line.StartsWith("/*")
            ;     InCommentBlock := true
            ; else if line.StartsWith("*/")
            ;     InCommentBlock := false

            ; if InCommentBlock
            ;     continue

            ; if StartsWith.Contains("#Include")
            ;  if FunctionName.Contains("ScanLibScript")
            ;      Debug.MBox("StartsWith: " StartsWith "`n`nFunctionName: " FunctionName, "FindIn")

            if line.StartsWith(StartsWith) AND line.Contains(FunctionName) {
                found := true
                 ;Debug.MBox("debugCount: " debugCount "`n`nFunctionName: " FunctionName, "FindIn")
                break
            }

        }
        ;Debug.MBox("debugCount: " debugCount "`n`nFunctionName: " FunctionName, "FindIn")

        return found
    }
    static _FindInLibrary(IncludeLine) {

        if FileExist(IncludeLine)
            Return IncludeLine
            
        if Not IncludeLine.StartsWith("#")
            Return ""
                
        if IncludeLine.Contains(">") {	
            fname := IncludeLine.Match("<(.+?)>")
            fname := fname.IsEmpty() ? "" : fname.Trim()
        } else {
            split := StrSplit(IncludeLine, " ")
            fname := split.Length >= 2 ? split[2].Trim() : ""
        }

        if !IsSet(fname) OR fname.IsEmpty()
            return

        fname := fname.EndsWith(".ahk") ? fname : fname ".ahk"

        loclib := A_ScriptDir   "\Lib\"             fname
        usrlib := A_MyDocuments "\AutoHotkey\Lib\"  fname
        stdlib := Ahkpath       "\Lib\"             fname

        libraries := loclib "," usrlib "," stdlib

        libfile := ""

        Loop Parse libraries, "CSV"
        {
            if (FileExist(A_LoopField)) {
                libfile := A_LoopField
                Break		
            }
        }
        return FileExist(libfile) ? libfile : ""
    }
}

; Purpose:  Find Functions to include in the MainScriptFile.
; Return:   CSV file of functionName, LibScriptFile, ScriptLineNumber, FunctionLineCount.
;----------------------------------------------------------------------------------------
ScanLibScript(LibScriptFile) {

    FunctionCSV := ""

    ScriptText := FileRead(LibScriptFile)

    ScriptTextArray := StrSplit(ScriptText, "`n", "`r")

    ClassBlockStart := false
    InClassBlock := false
    InCommentBlock := false
    ScriptLineNumber := 0
    IgnoreToEnd := False

    Loop {
   
        if IgnoreToEnd
            break

        ScriptLineNumber++

        if ScriptLineNumber > ScriptTextArray.Length
            break

        functionName := ""

        ;remove leading whitespace
        line := ScriptTextArray[ScriptLineNumber].LTrim()

        if line.StartsWith("/*")
            InCommentBlock := true
        else if line.StartsWith("*/")
            InCommentBlock := false

        if InCommentBlock
            continue

        if line.IsEmpty() OR line.StartsWith(";")
            continue

        ; Exclude test functions at bottom of script
        if line.StartsWith("If (A_LineFile == A_ScriptFullPath)") {
            IgnoreToEnd := True
            continue
        }

        if line.StartsWith("class") {

            ClassBlockStart := true

            ;match the second word
            ;functionName := line.Match("^\s*\S+\s+(\S+)")

            ; if class search for the name of the class e.g. class Debug {, Debug.ahk
            ;functionName := LibScriptFile.SplitPath().NameNoExt
            functionName := "#Include"

            ;Debug.MBox("LibScriptFile: " LibScriptFile "`n`nfunctionName: " functionName)

            ;OutputDebug("class: " line ", name: " r)

        }

        if functionName.IsEmpty() {
            ; This RegExMatch pattern will find and capture the function name: ".*?(\w+)\("
            ;   .*?     : This is a non-greedy match for any character (.) zero or more times (*?).
            ;               It will match as few chars as possible from the beginning of the string until the next part of the pattern can be satisfied.
            ;               This is useful for skipping over things like if or leading whitespace.
            ;   (\w+)   : This is the capturing group.
            ;               It matches one or more "word" characters (letters, numbers, and underscores).
            ;               This will capture the function name (e.g., DirExist).
            ;   \(      : This matches the literal opening parenthesis that immediately follows the function name, 
            ;               confirming it's a function call.
            RegExMatch(line, ".*?(\w+)\(", &match)

            if !IsObject(match)
                continue

            functionName := match[1]

            ;Debug.WriteLine("functionName: " functionName)
            ;Debug.MBox("functionName: " functionName)

        }

        ; if still empty we didn't detect a function name in this line, continue
        if functionName.IsEmpty()
            continue

        ;static excludedFunctionNames := "for, if, MsgBox, while"
        static excludedFunctionNames := "MsgBox"

        if excludedFunctionNames.Contains(functionName)
            continue

        ;If next line > end of Array then Break
        if (ScriptLineNumber + 1) > ScriptTextArray.Length
            break

        ;If next line starts with { then add { to this line and clear next line
        if ScriptTextArray[ScriptLineNumber + 1].StartsWith("{") {
            ScriptTextArray[ScriptLineNumber] .= "{"
            ScriptTextArray[ScriptLineNumber + 1] := ""        
        }

        ;if not in class block, save the function, script name, and line number
        if FunctionCSV.Contains(functionName)
            continue

        if NOT InClassBlock
            FunctionCSV .= functionName ", " LibScriptFile ", " ScriptLineNumber

        if ClassBlockStart
            InClassBlock := true

        ; Preset counters
        FunctionLineCount := 1
        BraceCount := 0

    ;MsgBox "Script: " OutName "`n`nFunctionName:`n`n" functionName "`n`nlineNumber: " ScriptLineNumber "`n`nInCommentBlock: " InCommentBlock, "Loop 1"

        ; If this line contains { then Count braces
        if ScriptTextArray[ScriptLineNumber].Contains("{") {

    ;MsgBox "Script: " OutName "`n`nCounting Braces.", "Loop 1"

            Loop {

                line := ScriptTextArray[ScriptLineNumber]

                if line.Contains("}") and line.Contains("{") {
                    BraceCount += 0
                } else if line.Contains("{") {
                    BraceCount += 1
                } else if line.Contains("}") {
                    BraceCount -= 1
                }

    ;MsgBox "Script: " OutName "`n`nScriptLineNumber: " ScriptLineNumber "`n`nBraceCount: " BraceCount , "Loop 1"

                if (BraceCount = 0) {
                    ;DEBUG THIS ISN'T USED, REMOVE
                    if InClassBlock
                        InClassBlock := false
                    break
                }
                
                FunctionLineCount++

                ScriptLineNumber++
                
                if ScriptLineNumber > ScriptTextArray.Length
                    break ; 2
            }

        }

        FunctionCSV .= ", " FunctionLineCount "`n"

    } ; end loop

    ;Debug.ListVar FunctionCSV

    return FunctionCSV
}

GetFunctionLineCount(Buffer, FunctionName, LineNumber) {

;TODO: Buffer[] needs to be an Array so we can step through it to count function lines

    ;MsgBox "FunctionName: " FunctionName ", LineNumber: " LineNumber, "GetFunctionLineCount"

    FunctionLineCount := BraceCount := 0

    Loop Parse Buffer, "`n" {

    ;     split := StrSplit(A_LoopField, ",")

    ; MsgBox "split[3]: " split[3], "Loop"

        ; if split.Length >= 4
        ;     lineNumber := split[3]
        ; else
        ;     continue

        if A_Index != lineNumber
            continue

        ; Found Function in Buffer, now count braces
        line := A_LoopField.Trim()

        Loop {

            FunctionLineCount := 0
        
        ;MsgBox "line: " line "`n`nlineNumber: " lineNumber, "Loop"

        ;MsgBox "lineNumber: " lineNumber, "Loop"

            if line.Contains("}") and line.Contains("{") {
                BraceCount += 0
            } else if line.Contains("{") {
                BraceCount += 1
            } else if line.Contains("}") {
                BraceCount -= 1
            }

            if (BraceCount = 0) {
                break
            }

            if (BraceCount > 0)
                FunctionLineCount++

        }
    }

    MsgBox "FunctionName: " FunctionName "`n`nBraceCount: " BraceCount "`n`nFunctionLineCount: " FunctionLineCount "`n`n", "Loop"

    return FunctionLineCount
}