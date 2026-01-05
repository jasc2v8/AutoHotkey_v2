
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <Debug>
#Include <JSON>

ArrayObj:= ["item1", "item2", "item3"]
Debug.ListVar(ArrayObj, "1: ArrayObj")

MapObj:= Map("Key1", "Value1", "Key2", "Value2", "Key3", "Value3")
Debug.ListVar( MapObj, "2: MapObj")

ArrayJSON:= JSON.ToString(ArrayObj)
Debug.ListVar(ArrayJSON, "3: ArrayJSON")

MapJSON := JSON.ToString(MapObj)
Debug.ListVar(MapJSON, "4: MapJSON")

ArrayObj := JSON.ToObject(ArrayJSON)
Debug.ListVar(ArrayObj, "5: ArrayObj")

MapObj := JSON.ToObject(MapJSON) 
Debug.ListVar(MapObj, "6: MyObj")


