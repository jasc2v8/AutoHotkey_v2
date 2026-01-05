; ABOUT:Array extends Object
; From:
; License:
/*
    TODO: 
*/
#Requires AutoHotkey v2.0+

; Array extends Object
; That means Arrays also get Object methods
; And because Object inherits from Any, that means Array inherits from Any
class Array extends Object {
    ; New Array methods
    Clone() => 1
    Delete() => 1
    Get() => 1
    Has() => 1
    InsertAt() => 1
    Pop() => 1
    Push() => 1
    RemoveAt() => 1
    __New() => 1
    __Enum() => 1
    
    ; New Array properties
    Length := 1
    Capacity := 1
    Default := 1
    __Item := 1
    
    ; Base is always updated to the extending class
    Base := Object

    ; Methods inherited from Object
    Base.Clone() => 1
    Base.DefineProp() => 1
    Base.DeleteProp() => 1
    Base.GetOwnPropDesc() => 1
    Base.HasOwnProp() => 1
    Base.OwnProps() => 1
    
    
    ; Methods inherited from Any
    Base.Base.GetMethod() => 1
    Base.Base.HasBase() => 1
    Base.Base.HasMethod() => 1
    Base.Base.HasProp() => 1
}