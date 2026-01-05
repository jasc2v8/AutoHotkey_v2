
#Requires AutoHotkey v2.0+
#SingleInstance Force
#NoTrayIcon

#Include <Peep>
#Include <JSON>

ArrayObj:= ["item1", "item2", "item3"]
Peep("1: ArrayObj", ArrayObj)

MapObj:= Map("Key1", "Value1", "Key2", "Value2", "Key3", "Value3")
Peep("2: MapObj", MapObj)

ArrayJSON:= JSON.ToString(ArrayObj)
Peep("3: ArrayJSON", ArrayJSON)

MapJSON := JSON.ToString(MapObj)
Peep("4: MapJSON", MapJSON)

ArrayObj := JSON.ToObject(ArrayJSON)
Peep("5: ArrayObj", ArrayObj)

MapObj := JSON.ToObject(MapJSON) 
Peep("6: MyObj", MapObj)


