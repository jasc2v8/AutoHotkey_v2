; TITLS   : File v0.0
; SOURCE  : jasc2v8 12/154/2025
; LICENSE : The Unlicense, see https://unlicense.org

/*
  TODO:
    
*/
#Requires AutoHotkey 2.0+

Class FileHelper {

  static DefaultFilePath:= A_ScriptDir

  __Call(FilePath) {
    this.DefaultFilePath:= FilePath
  }

  static Select(Options:='', FilePath:=this.DefaultFilePath, Title:='Select File', Filter:='*.*') {
    selection := FileSelect(Options, FilePath)
    if (selection != "")
      return selection
    else
      return ''
  }

  ;----------------------------------------------------------------------------
  ; FUNCTION: StrJoinPath(Parts*)
  ; Purpose: Joins the path parts with the '\' separator.
  ; Returns: Joined path without duplicate separators.
  ; Library: String
  static JoinPath(Parts*) {
      Separator := '\'
      joinedPath := ""
      for index, value in Parts {
          joinedPath .= value . Separator
      }
      while (InStr(joinedPath, Separator Separator) > 0)
          joinedPath := StrReplace(joinedPath, Separator . Separator, Separator)
      return SubStr(joinedPath, 1, -StrLen(Separator))
  }
  ;-------------------------------------------------------------------------------
  ; FUNCTION: StrSplitPath(path)
  ; Purpose: Splits the path into its components.
  ; Returns: Each component as a Map object.
  ; Library: String
  static SplitPath(path) {
      path := StrReplace(path, "\\", "\")
      SplitPath(path, &FileName, &Dir, &Ext, &NameNoExt, &Drive)
      SplitPath(Dir,,&ParentDir)
      return {FullPath: path, ParentDir: ParentDir, FileName: FileName, Dir: Dir, Ext: Ext, NameNoExt: NameNoExt, Drive: Drive}
  }

}
