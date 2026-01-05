; TITLS   : File v0.0
; SOURCE  : jasc2v8 12/154/2025
; LICENSE : The Unlicense, see https://unlicense.org

/*
  TODO:
    
*/
#Requires AutoHotkey 2.0+

Class FileHelper {

  static DefaultFilePath:= ''

  __Call(FilePath) {
    this.DefaultFilePath:= FilePath
  }

  static FileSelect(Options:='', FilePath:=this.DefaultFilePath) {
    selection := FileSelect(Options, FilePath)
    if (selection != "")
      return selection
    else
      return ''
  }

}
