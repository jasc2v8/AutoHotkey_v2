
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include ObjView.ahk
#Include <JSON>

ArrayObj:= ["item1", "item2", "item3"]
ObjView("1: ArrayObj", ArrayObj)

MapObj:= Map("Key1", "Value1", "Key2", "Value2", "Key3", "Value3")
ObjView("2: MapObj", MapObj)

ArrayJSON:= JSON.ToString(ArrayObj)
ObjView("3: ArrayJSON", ArrayJSON)

MapJSON := JSON.ToString(MapObj)
ObjView("4: MapJSON", MapJSON)

ArrayObj := JSON.ToObject(ArrayJSON)
ObjView("5: ArrayObj", ArrayObj)

MapObj := JSON.ToObject(MapJSON) 
ObjView("6: MyObj", MapObj)


