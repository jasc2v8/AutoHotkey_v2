; ABOUT:    MyScript v0.0
; SOURCE:   Ahkv1 A_AhkUser https://www.autohotkey.com/boards/viewtopic.php?t=30038
; LICENSE:  The Unlicense, see https://unlicense.org

/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon


list := "Active COM Objects:`n"

for name, obj in GetActiveObjects() {
    list .= name "`n"
}

MsgBox(list)


    ; https://www.autohotkey.com/boards/viewtopic.php?f=82&t=80074&p=524410&hilit=GetActiveObjects#p524410
	; for AHK V1 by lexikos http://ahkscript.org/boards/viewtopic.php?f=6&t=6494
	; for AHK V2 by fatodubs https://www.autohotkey.com/boards/viewtopic.php?f=82&t=80074&hilit=GetActiveObjects
	; gets all active comObjects that are available on the system
	GetActiveObjects(Prefix:="",CaseSensitive:="Off") {
		objects:=Map()
		DllCall("ole32\CoGetMalloc", "uint", 1, "ptr*", &malloc:=0) ; malloc: IMalloc
		DllCall("ole32\CreateBindCtx", "uint", 0, "ptr*", &bindCtx:=0) ; bindCtx: IBindCtx
		ComCall(8, bindCtx, "ptr*",&rot:=0) ; rot: IRunningObjectTable
		ComCall(9, rot, "ptr*", &enum:=0) ; enum: IEnumMoniker
		while (ComCall(3, enum, "uint", 1, "ptr*", &mon:=0, "ptr", 0)=0) ; mon: IMoniker
		{
			ComCall(20, mon, "ptr", bindCtx, "ptr", 0, "ptr*", &pname:=0) ; GetDisplayName
			name:=StrGet(pname, "UTF-16")
			ComCall(5,malloc,"ptr",pname) ; Free
			if ((Prefix="") OR (InStr(name,Prefix,CaseSensitive)=1)) {
				try {
					ComCall(6, rot, "ptr", mon, "ptr*", &punk:=0) ; GetObject											; can throw an Error: (0x800401FB) Object is not registered - probably when an app is closed and is suddenly unavailable
					; Wrap the pointer as IDispatch if available, otherwise as IUnknown.
					obj:=ComObjFromPtr(punk)
					objects[name]:=obj
				}
			}
			ObjRelease(mon)
		}
		ObjRelease(enum)
		ObjRelease(rot)
		ObjRelease(bindCtx)
		ObjRelease(malloc)
		return objects
	}
