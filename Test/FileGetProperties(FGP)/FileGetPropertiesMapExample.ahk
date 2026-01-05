;ABOUT: Retrieves all file properties from an executable

#Requires AutoHotkey v2.0
#SingleInstance Force
;#NoTrayIcon


#Include <String>

;FileSelectFile, FilePath					; Select a file to use for this example.
;FilePath := FileSelect(,"D:\Software\DEV\Work\AHK2\Projects\AhkLauncher\AhkLauncher.exe")
;;FilePath := FilePath := "C:\Program Files\AutoHotkey\V2\AutoHotkey.exe"
FilePath := "D:\Software\DEV\Work\AHK2\Projects\AhkLauncher\AhkLauncher.exe"

OutputDebug("FilePath: " FilePath)
MyMap := Map()
MyMap := FileGetPropertiesMap(FilePath)
;Exit
strList := DisplayObj(MyMap)
OutputDebug("Len: " StrLen(strList))
OutputDebug("list: " strList)
OutputDebug("end")
Exit

;ok
;MyList := FileGetPropertiesMap_MERGED(FilePath)
;list := DisplayObj(MyList)
;OutputDebug("list: " list)

PropName := FGP_Name(0)						; Gets a property name based on the property number.
PropNum  := FGP_Num("Size")					; Gets a property number based on the property name.
; ok PropNum  := FGP_Num("Language")					; Gets a property number based on the property name.
PropVal1 := FGP_Value(FilePath, PropName)	; Gets a file property value by name.
PropVal2 := FGP_Value(FilePath, PropNum)	; Gets a file property value by number.
PropList := FGP_List(FilePath)				; Gets all of a file's non-blank properties.

; MsgBox(
;     "PropName :`t" PropVal1 "`n`n" 
;     "PropNum :`t" PropVal2 " (#" PropNum ")`n`n"
;     "List:`n`n" PropList.CSV)


;v2 source: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=3806&start=20

FileGetPropertiesMap(FilePath) {
    PropNumMap := Map()
    PropValMap := Map()
    PromNumArray := []
   	SplitPath(FilePath, &FileName, &DirPath)
	oShell := ComObject("Shell.Application")
	oFolder := oShell.NameSpace(DirPath)
	oFolderItem := oFolder.ParseName(FileName)
    Gap := 0
    while (Gap < 11) { ; if this number of null items, we have all we need
        PropNum := A_Index - 1
        if (PropName := oFolder.GetDetailsOf(0, PropNum)) {
            if (PropVal := oFolder.GetDetailsOf(oFolderItem, PropNum)) {
                ;OutputDebug(PropNum ", " PropName ", " PropVal)
                PropValMap[PropName] := PropVal
            }
            Gap := 0
        } else {
            Gap++
        }
    }
	return PropValMap
 }

FileGetPropertiesMap_MERGED(FileName) {

    return FGP_List(Filename)

     FGP_Init() {
        static PropTable
        if (!IsSet(PropTable)) {
            ;PropTable := {Name:={},Num:={} }
            ;PropTable := {{},{}}
            PropTable := {}
            PropTable.Name := Map()
            PropTable.Num := Map()
            Gap := 0
            oShell := ComObject("Shell.Application")
            oFolder := oShell.NameSpace(0)
            while (Gap < 11)
                {
                if (PropName := oFolder.GetDetailsOf(0, A_Index - 1)) 
                    {
                    PropTable.Name[PropName] := A_Index - 1
                    PropTable.Num[A_Index - 1] := PropName 
                    ;PropTable.Num.InsertAt( A_Index - 1 , PropName )
                    Gap := 0
                    }
                else
                    {
                    Gap++
                    }
                }
            }
        return PropTable
    }

    FGP_List(FilePath) {
        static PropTable := FGP_Init()
        SplitPath(FilePath, &FileName, &DirPath)
        oShell := ComObject("Shell.Application")
        oFolder := oShell.NameSpace(DirPath)
        oFolderItem := oFolder.ParseName(FileName)
        PropList := {}
        PropList.Name := Map()
        PropList.Num := Map()
        PropList.CSV := ""
        for PropNum, PropName in PropTable.Num
            if (PropVal := oFolder.GetDetailsOf(oFolderItem, PropNum)) {
                PropList.Num[PropNum] := PropVal
                PropList.Name[PropName] := PropVal
                PropList.CSV .= PropNum ", " PropName ", " PropVal "`r`n"
            }
        PropList.CSV := RTrim(PropList.CSV, "`r`n")
        return PropList

    }
}


/*  FGP_Init()
 *		Gets an object containing all of the property numbers that have corresponding names. 
 *		Used to initialize the other functions.
 *	Returns
 *		An object with the following format:
 *			PropTable.Name["PropName"]	:= PropNum
 *			PropTable.Num[PropNum]		:= "PropName"
 */
 FGP_Init() {
	static PropTable
	if (!IsSet(PropTable)) {
        ;PropTable := {Name:={},Num:={} }
        ;PropTable := {{},{}}
        PropTable := {}
        PropTable.Name := Map()
        PropTable.Num := Map()
        Gap := 0
		oShell := ComObject("Shell.Application")
		oFolder := oShell.NameSpace(0)
		while (Gap < 11)
            {
			if (PropName := oFolder.GetDetailsOf(0, A_Index - 1)) 
                {
				PropTable.Name[PropName] := A_Index - 1
				PropTable.Num[A_Index - 1] := PropName 
                ;PropTable.Num.InsertAt( A_Index - 1 , PropName )
				Gap := 0
			    }
			else
                {
				Gap++
                }
	        }
        }
	return PropTable
}



/*  FGP_List(FilePath)
 *		Gets all of a file's non-blank properties.
 *	Parameters
 *		FilePath	- The full path of a file.
 *	Returns
 *		An object with the following format:
 *			PropList.CSV				:= "PropNum,PropName,PropVal`r`n..."
 *			PropList.Name["PropName"]	:= PropVal
 *			PropList.Num[PropNum]		:= PropVal
 */
FGP_List(FilePath) {
	static PropTable := FGP_Init()
	SplitPath(FilePath, &FileName, &DirPath)
	oShell := ComObject("Shell.Application")
	oFolder := oShell.NameSpace(DirPath)
	oFolderItem := oFolder.ParseName(FileName)
    PropList := {}
    PropList.Name := Map()
    PropList.Num := Map()
    PropList.CSV := ""
	for PropNum, PropName in PropTable.Num
		if (PropVal := oFolder.GetDetailsOf(oFolderItem, PropNum)) {
			PropList.Num[PropNum] := PropVal
			PropList.Name[PropName] := PropVal
			PropList.CSV .= PropNum ", " PropName ", " PropVal "`r`n"
		}
	PropList.CSV := RTrim(PropList.CSV, "`r`n")
	return PropList
}



/*  FGP_Name(PropNum)
 *		Gets a property name based on the property number.
 *	Parameters
 *		PropNum		- The property number.
 *	Returns
 *		If succesful the file property name is returned. Otherwise:
 *		-1			- The property number does not have an associated name.
 */
FGP_Name(PropNum) {
	static PropTable := FGP_Init()
	if (PropTable.Num[PropNum] != "")
		return PropTable.Num[PropNum]
	return -1
}


/*  FGP_Num(PropName)
 *		Gets a property number based on the property name.
 *	Parameters
 *		PropName	- The property name.
 *	Returns
 *		If succesful the file property number is returned. Otherwise:
 *		-1			- The property name does not have an associated number.
 */
FGP_Num(PropName) {
	static PropTable := FGP_Init()
	if (PropTable.Name[PropName] != "")
		return PropTable.Name[PropName]
	return -1
}


/*  FGP_Value(FilePath, Property)
 *		Gets a file property value.
 *	Parameters
 *		FilePath	- The full path of a file.
 *		Property	- Either the name or number of a property.
 *	Returns
 *		If succesful the file property value is returned. Otherwise:
 *		0			- The property is blank.
 *		-1			- The property name or number is not valid.
 */
FGP_Value(FilePath, Property) {
	static PropTable := FGP_Init()
	if ((PropNum := PropTable.Name.Has(Property) ? PropTable.Name[Property] : PropTable.Num[Property] ? Property : "") != "") {
		SplitPath(FilePath, &FileName, &DirPath)
		oShell := ComObject("Shell.Application")
		oFolder := oShell.NameSpace(DirPath)
		oFolderItem := oFolder.ParseName(FileName)
		if (PropVal := oFolder.GetDetailsOf(oFolderItem, PropNum))
			return PropVal
		return 0
	}
	return -1
}

DisplayObj(Obj, Depth:=5, IndentLevel:="")
{
	if Type(Obj) = "Object"
		Obj := Obj.OwnProps()
	for k,v in Obj
	{
		List.= IndentLevel "[" k "]"
		if (IsObject(v) && Depth>1)
			List.="`n" DisplayObj(v, Depth-1, IndentLevel . "    ")
		Else
			List.=" => " v
		List.="`n"
	}
	return RTrim(List)
}