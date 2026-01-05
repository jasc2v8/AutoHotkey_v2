; THIS IS INOP
; started to convert AHKv1 to v2
; but I realized I like my simple GuiLayout better.



/************************************************************************
 * @description 
 * @author 
 * @source cmann https://www.autohotkey.com/boards/viewtopic.php?style=8&t=2932
 * @date 2025/11/15
 * @version 0.0.0
 ***********************************************************************/


/*
    TODO:
*/

#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <String>

; Creates either a container or control component
;     ControlHwnd		- The Hwnd of the control to associate with this component or 0 if this component is only a container for other controls/components.
;						  A component may have an associated control and contain other components at the same time.
;						  A component's control will automatically assume the size of the component
;     ParentComponent	- The parent component that the new component will belong to
;     LayoutRules		- Defines how this component will be sized and positioned within its parent container.
;						  This must be a string with each value or rule seperated ba a single space, the following rules are recognised:
;						  - l/r/t/b	: Stands for left, right, top, and bottom. Anchors the corresponding side of the component to its parent.
;									  A value must follow directly after the the letter, the following types are recognised:
;									  - A plain pixel value, eg. r100 will anchor the component's right hand side 100 pixels from its parent's right side.
;									  - A percentage value, eg. r25% will anchor the component's right hand side 25% of its parent's width from t
;									  - For percent values an offset may also be given by using either a + or - followed be the offset, eg. r50%+5 will
;										anchor the right hand side in the middle of its parent, plus five pixels. This can be useful for adding padding between components.
;									  - You can also have the anchor automatically be calculated based on the previous component, eg. r>5 will take the r value and width
;										of the previously defined component and calculate this component's r values based on that so that it is placed just left of it plus five pixels.
;										This can be useful for quickly creating rows or columns of components without having to manually enter anchor values
;						  - w/h		: By default if a component has an associated control it will automatically assume the size of that control if needed. Using the w and h rules you can change
;									  the control's or set a size for container components that do not have associated controls. These options only support simple pixel values.
;									  the control's or set a size for container components that do not have associated controls. These options only support simple pixel values.
;									  If a component already has both an l/t and an r/b rule the w and h options will have no effect since the component's size will be calculated
;									  based on the l/t and r/b options and size of its parent 
;						  - nd		: By default when a component is moved or sized during layout it will use the GuiControl MoveDraw command, if the nd (no draw) flag is present then 
;									  the Move command will be used instead
; Return - A GuiLayout Component object
GuiLayout_Create(ControlHwnd := 0, ParentComponent := 0, LayoutRules := ""){
    
	static CurrentId := 1 , PreviousComponent := 0
	
	Component := Map()
    Component.Set("Id:", CurrentId)

    ; ParentComponent.Children to ParentComponentChildren
; Children := Map()

	if(ControlHwnd) {
		Component.Set("ControlHwnd", ControlHwnd)

		;ControlHwnd.Move(,,138) ;debug this does make the edit s138
	}
	
	; Add this component to its parent

	; if(IsSet(ParentComponent))
	; 	debug:=true

	
	if(IsSet(ParentComponent)){

		if IsSet(ParentComponentChildren) {

			if (Children := ParentComponentChildren)
				Children.Set(CurrentId, Component)
		}
		else {
			ParentComponentChildren := Map()
			ParentComponentChildren.Set(CurrentId, Component)
		}
	}
	
	; Parse the layout rules
	
	Loop Parse, LayoutRules, A_Space
	{
		; NoDraw flag
		if(A_LoopField = "nd"){
			Component.Set("nd", 1)
			continue
		}
		
		RulePosition := SubStr(A_LoopField, 1, 1)
		, RuleValue := RV := SubStr(A_LoopField, 2)
		, RuleOffset := 0
		, RuleValueIsPixels := 1
		
		; Width and height only support regular pixel values
		if(RulePosition = "w" or RulePosition = "h"){
			Component[RulePosition] := RuleValue
			continue
		}
		
		; Calculate an offset and position based on the position and size of the previous control
		if(SubStr(RuleValue, 1, 1) = ">"){
			RuleValue := SubStr(RuleValue, 2)
			
			if(RulePosition = "l" or RulePosition = "r"){
				PrevL := PreviousComponent.Has("l") ? PreviousComponent["l"] : 0
				PrevLP := PreviousComponent.Has("lp") ? PreviousComponent["lp"] : 0
				PrevR := PreviousComponent.Has("r") ? PreviousComponent["r"] : 0
				PrevRP := PreviousComponent.Has("rp") ? PreviousComponent["rp"] : 0
				PrevS := PreviousComponent.Has("w") ? PreviousComponent["w"] : 0
			}
			else{
				PrevL := PreviousComponent["t"] ? PreviousComponent["t"] : 0
				PrevLP := PreviousComponent["tp"] ? PreviousComponent["tp"] : 0
				PrevR := PreviousComponent["b"] ? PreviousComponent["b"] : 0
				PrevRP := PreviousComponent["bp"] ? PreviousComponent["l"] : 0
				PrevS := PreviousComponent["h"] ? PreviousComponent["h"] : 0
			}
			
			if(PrevL != ""){
				if(PrevLP)
					RuleOffset := RuleValue + PrevS
					, RuleValue := PrevL
					, RuleValueIsPixels := 0
				else
					RuleValue += PrevL + PrevS
			}
			else if(PrevR != ""){
				if(PrevRP)
					RuleOffset := RuleValue + PrevS
					, RuleValue := PrevR
					, RuleValueIsPixels := 0
				else
					RuleValue :=  PrevR + PrevS + RuleValue
			}
		}
		
		; Check for an extra offset value eg. 50%+4
		else if( (Pos := InStr(RuleValue, "+")) )
			RuleOffset := SubStr(RuleValue, Pos + 1)
			, RuleValue := SubStr(RuleValue, 1, Pos - 1)
		; > A negative offset
		else if( (Pos := InStr(RuleValue, "-")) and Pos != 1 )
			RuleOffset := -SubStr(RuleValue, Pos + 1)
			, RuleValue := SubStr(RuleValue, 1, Pos - 1)
		
		; Check for ap percentage value instead of a pixel value
		if(SubStr(RuleValue, 0) = "%")
			RuleValueIsPixels := 0
			, RuleValue := SubStr(RuleValue, 1, -1) / 100
		
		Component[RulePosition] := RuleValue
		if(RuleOffset)
			Component[RulePosition "o"] := RuleOffset
		if(!RuleValueIsPixels)
			Component[RulePosition "p"] := 1
	}
	
	; Get the control size if needed, eg. if an "r" value is set but no "l" we will need to know the width
	; of the control so that its x position can be calculate relative to the right side of its parent
	if(ControlHwnd){
		GetSize := 0
		if(Component.Has("l") != Component.Has("r") and !Component.Has("w"))
			GetSize := 1, SetWidth := 1
		else
			SetWidth := 0
		if(Component.Has("t") != Component.Has("b") and !Component.Has("h"))
			GetSize := 1, SetHeight := 1
		else
			SetHeight := 0
		
		if(Component.Has("w") or Component.Has("h")){
			;Position := (Component.Has("w") != "" ? "w" Component.w : "") (Component.Has("h") ? " h" Component.h : "")
			Position  := Component.Has("w") ? " w" Component["w"] : ""
		 	Component := Component.Has("h") ? " h" Component["h"] : ""
			;GuiControl Move, ControlHwnd, Position
			;ControlMove [X, Y, Width, Height, Control, WinTitle, WinText, ExcludeTitle, ExcludeText]
			;GuiCtrl.Move([X, Y, Width, Height])
			;ControlHwnd.Move(Position)
			ControlHwnd.Move(,,138)
			nop:=true


		}
		
		if(GetSize){
			;ControlGetPos , , &ControlW, &ControlH, , "ahk_id " ControlHwnd.Hwnd
			ControlGetPos , , &ControlW, &ControlH, ControlHwnd.Hwnd
			if(SetWidth)
				Component["w"] := ControlW
			if(SetHeight)
				Component["h"] := ControlH
		}
	}
	
	CurrentId++
	return PreviousComponent := Component
}

;==========================================================
; EXAMPLE
;==========================================================


;Gui New, Resize
g := Gui("Resize", "GuiLayout")
;g := Gui(, "GuiLayout")
EditHwnd := g.AddEdit("Multi", "Testing")
BtnAddHwnd          := g.AddButton(,"Add")
BtnRemoveHwnd       := g.AddButton(,"Remove")
BtnUpHwnd           := g.AddButton(,"Up")
BtnDownHwnd         := g.AddButton(,"Down") 
GroupBoxTopHwnd     := g.AddGroupBox(,"Top")
; RightPanelEditHwnd  := g.AddEdit("Multi", "Testing")
; RightPanelEditHwnd  := g.AddEdit("Multi", "Testing")
; RightPanelBtnHwnd   := g.AddButton(,"Click")
; GroupBoxBottomHwnd  := g.AddGroupBox(,"Bottom")
g.Show("w480 h360")

;DEBUG
#Warn Unreachable, off

; Create a "root" component which will correpsond to the window client area
LayoutRoot := GuiLayout_Create()
	; Create two container components for the left and right columns for convenience
	LayoutLeft := GuiLayout_Create(0, LayoutRoot, "l6 t16 r150 b6") ; "l6 t6 r150 b6"

		GuiLayout_Create(EditHwnd, LayoutLeft, "l0 t0 r0 b30") ; "l0 t0 r0 b30"

		; Create a row of buttons, only specify the r rule for the first button, then r>6 for the following buttons to automatically position them 6 pixels from the previous one
		GuiLayout_Create(BtnAddHwnd, LayoutLeft, "r0 b0")
		GuiLayout_Create(BtnRemoveHwnd, LayoutLeft, "r>6 b0")
		return

		GuiLayout_Create(BtnUpHwnd, LayoutLeft, "r>6 b0")
		GuiLayout_Create(BtnDownHwnd, LayoutLeft, "r>6 b0")
	; LayoutRightTop := GuiLayout_Create(GroupBoxTopHwnd, LayoutRoot, "w138 r6 t6 b50%-3") ; b50%-3 is used to give a 6 pixel spacing between this component and the one below it
	; 	GuiLayout_Create(RightPanelEditHwnd, LayoutRightTop, "l6 r6 t20")
	; 	GuiLayout_Create(RightPanelBtnHwnd, LayoutRightTop, "r6 b6")
	; LayoutRightBottom := GuiLayout_Create(GroupBoxBottomHwnd, LayoutRoot, "w138 r6 t50%+3 b6")

return