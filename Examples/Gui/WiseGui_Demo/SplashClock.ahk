SplashClock()
{
    WiseGui("SplashClock"
          , "FontMain:    s24 Norm,      Consolas"
          , "FontSub:     s48 Norm Bold, Consolas"
          , "MainText:" . FormatTime(A_Now, "ddd, dd-MMM-yyyy (") . FormatTime(A_Now, "YDay0") . ")"
          , "SubText:"  . FormatTime(A_Now, "hh:mm:ss tt")
          , "MainAlign:   0"
          , "SubAlign:    0"
          , "Margins:     4,4,2,0"
          , "Move:"                                        ; Center screen
          , "TextWidth:   420"
          , "Theme:       0x856442, 0xFFFFF0, 0xEBB800, 0" ; Same as Warning theme, but no Icon
          , "Show:        Fade@400ms"
          , "Hide:        Fade@400ms"
    )

    SetTimer( SplashClock, 900 )

    SplashClock()
    {
        If ( WinExist("WiseGui\SplashClock ahk_class AutoHotkeyGUI") )
             WiseGui("SplashClock", "SubText:" . FormatTime(A_Now, "hh:mm:ss tt"))
        Else SetTimer( , 0 )
    }
}
