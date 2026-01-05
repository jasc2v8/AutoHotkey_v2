; =================================================================================
; Function: AutoXYWH
;   Move and resize control automatically when GUI resizes.
; Parameters:
;   DimSize - Can be one or more of x/y/w/h  optional followed by a fraction
;             add a '*' to DimSize to 'MoveDraw' the controls rather then just 'Move', this is recommended for Groupboxes
;             add a 't' to DimSize to tell AutoXYWH that the controls in cList are on/in a tab3 control
;   cList   - variadic list of GuiControl objects
;
; Examples:
;   AutoXYWH("xy", "Btn1", "Btn2")
;   AutoXYWH("w0.5 h 0.75", hEdit, "displayed text", "vLabel", "Button1")
;   AutoXYWH("*w0.5 h 0.75", hGroupbox1, "GrbChoices")
;   AutoXYWH("t x h0.5", "Btn1")
; ---------------------------------------------------------------------------------
; Version: 2023-02-25 / converted to v2 (Relayer)
;          2020-5-20 / small code improvements (toralf)
;          2018-1-31 / added a line to prevent warnings (pramach)
;          2018-1-13 / added t option for controls on Tab3 (Alguimist)
;          2015-5-29 / added 'reset' option (tmplinshi)
;          2014-7-03 / mod by toralf
;          2014-1-02 / initial version tmplinshi
; requires AHK version : v2+
; =================================================================================

AutoXYWH(DimSize, cList*)   ;https://www.autohotkey.com/boards/viewtopic.php?t=1079
{
	static cInfo := map()

	if (DimSize = "reset")
		Return cInfo := map()

	for i, ctrl in cList
	{
		ctrlObj := ctrl
		ctrlObj.Gui.GetPos(&gx, &gy, &gw, &gh)
		if !cInfo.Has(ctrlObj)
		{
			ctrlObj.GetPos(&ix, &iy, &iw, &ih)
			MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
			f := map( "x", 0
					, "y", 0
					, "w", 0
					, "h", 0 )

			for i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]"))) 
				if !RegExMatch(DimSize, "i)" . dim . "\s*\K[\d.-]+", &tmp)
					f[dim] := 1
				else
					f[dim] := tmp

			if (InStr(DimSize, "t"))
			{
				hWnd := ctrlObj.Hwnd
				hParentWnd := DllCall("GetParent", "Ptr", hWnd, "Ptr")
				RECT := buffer(16, 0)
				DllCall("GetWindowRect", "Ptr", hParentWnd, "Ptr", RECT)
				DllCall("MapWindowPoints", "Ptr", 0, "Ptr", DllCall("GetParent", "Ptr", hParentWnd, "Ptr"), "Ptr", RECT, "UInt", 1)
				ix := ix - NumGet(RECT, 0, "Int")
				iy := iy - NumGet(RECT, 4, "Int")
			}
			cInfo[ctrlObj] := {x:ix, fx:f["x"], y:iy, fy:f["y"], w:iw, fw:f["w"], h:ih, fh:f["h"], gw:gw, gh:gh, a:a, m:MMD}
		}
		else
		{
			dg := map( "x", 0
					 , "y", 0
					 , "w", 0
					 , "h", 0 )
			dg["x"] := dg["w"] := gw - cInfo[ctrlObj].gw, dg["y"] := dg["h"] := gh - cInfo[ctrlObj].gh
			ctrlObj.Move(  dg["x"] * cInfo[ctrlObj].fx + cInfo[ctrlObj].x
						 , dg["y"] * cInfo[ctrlObj].fy + cInfo[ctrlObj].y
						 , dg["w"] * cInfo[ctrlObj].fw + cInfo[ctrlObj].w
						 , dg["h"] * cInfo[ctrlObj].fh + cInfo[ctrlObj].h  )
			if (cInfo[ctrlObj].m = "MoveDraw")
				ctrlObj.Redraw()
		}
	}
}