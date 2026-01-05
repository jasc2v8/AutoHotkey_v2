
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <ListObj>
#Include <JSON>

ArrayObj:= ["item1", "item2", "item3"]
ListObj("1: ArrayObj", ArrayObj)

MapObj:= Map("Key1", "Value1", "Key2", "Value2", "Key3", "Value3")
ListObj("2: MapObj", MapObj)

ArrayJSON:= JSON.ToString(ArrayObj)
ListObj("3: ArrayJSON", ArrayJSON)

MapJSON := JSON.ToString(MapObj)
ListObj("4: MapJSON", MapJSON)

ArrayObj := JSON.ToObject(ArrayJSON)
ListObj("5: ArrayObj", ArrayObj)

MapObj := JSON.ToObject(MapJSON) 
ListObj("6: MyObj", MapObj)


