; TITLE  :  Colors v1.0.0.11
; SOURCE :  Gemini and jasc2v8
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Color names for Gui Backgrounds
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2+

class Colors {

    ; https://www.color-meanings.com/list-of-colors-names-hex-codes/#blue

    ;; --- FAVORITES ---
    static AirSuperiorityBlue   := "72A0C1"
    static AlaskanBlue          := "6DA9D2"
    static ArticBlue            := "C6E6FB"
    static CarolinaBlue         := "4B9CD3"
    static ColumbiaBlue         := "B9D9EB"
    static MarianBlue           := "E1EBEE"
    static NonPhotoBlue         := "A4DDED"
    static OceanBlue            := "009DC4"
    static SteelBlue            := "4682B4"
    static SteelBlueLight05     := "517FBF"
    static SteelBlueLight10     := "5888B9"
    static SteelBlueLight15     := "628FBE"
    static SteelBlueLight20     := "6B9BC3"
    static SteelBlueLight25     := "74A1C7"
    static SilverLakeBlue       := "5D89BA"
    static StoneBlue            := "819EA8"
    static WinterBlue           := "9EBACF"

    static MyGuiBackground      := this.CarolinaBlue ; this.SteelBlueLight15
    static GuiBlue              := this.CarolinaBlue

    static Gold                 := "FFD700"
    static SourLemon            := "FFEAA7"
    static Windstorm            := "6B9BC2"
    static WedgeWood            := "4E7F9E"

    static MyCtrlBackground     := "Backgroundffeaa7" ; #ffeaa7 Sour Lemon (flatuicolors)
    static MyBackgroundLemon    := "Backgroundffeaa7" ; #ffeaa7 Sour Lemon (flatuicolors)
    static CtrlLemon            := "Background" this.SourLemon
    
    ;; --- REDS ---
    static Red := "FF0000"
    static ImperialRed := "ED2939"
    static Scarlet := "FF2400"
    static IndianRed := "CD5C5C"
    static BarnRed := "7C0A02"
    static ChiliRed := "C21807"
    static FireBrick := "B22222"
    static Crimson := "B80F0A"
    static DarkRed := "8B0000"
    static Tomato := "FF6347"

    ;; --- BLUES ---
    static Blue := "0000FF"
    static NavyBlue := "000080"
    static Azure := "007FFF"
    static Cerulean := "007BA7"
    static SkyBlue := "87CEEB"
    static Turquoise := "40E0D0"
    static Teal := "008080"
    static RoyalBlue := "4169E1"
    static MidnightBlue := "191970"
    static CornflowerBlue := "6495ED"

    ;; --- GREENS ---
    static Green := "008000"
    static Lime := "00FF00"
    static Emerald := "50C878"
    static ForestGreen := "228B22"
    static Olive := "808000"
    static SageGreen := "9DC183"
    static MintGreen := "98FB98"
    static SeaGreen := "2E8B57"
    static JungleGreen := "29AB87"
    static KellyGreen := "4CBB17"

    ;; --- ORANGES ---
    static Orange := "FFA500"
    static Tangerine := "F28500"
    static DarkOrange := "FF8C00"
    static VividOrange := "FF5E0E"
    static Coral := "FF7F50"
    static Amber := "FFBF00"
    static Peach := "FFE5B4"
    static Apricot := "FBCEB1"
    static Pumpkin := "FF7518"
    static AlloyOrange := "C35214"

    ;; --- PURPLES & PINKS ---
    static Purple := "800080"
    static Magenta := "FF00FF"
    static Fuchsia := "C154C1"
    static Lavender := "E6E6FA"
    static Orchid := "DA70D6"
    static Plum := "DDA0DD"
    static Pink := "FFC0CB"
    static HotPink := "FF69B4"
    static DeepPink := "FF1493"
    static Amaranth := "E52B50"

    ;; --- W ---
    static WarmNeutral := "DABFAC"
    static WarmWhite := "FFF9F9"
    static WashTheDog := "FED85D"
    static WhippedCream := "F1ECD6"
    static Whisper := "F7F5FA"
    static WhiteChocolate := "EDE6D6"
    static WhiteLinen := "F8F0E8"
    static WhitePearl := "FDFDFD"
    static WildSand := "F4F4F4"

    ;; --- BLACKS ---
    static Black := "000000"
    static Ebony := "555D50"
    static Jet := "343434"
    static Onyx := "353839"
    static Charcoal := "36454F"
    static Licorice := "1A1110"
    static Midnight := "2B2B2B"
    static Oil := "3B3131"
    static Obsidian := "080808"
    static Raisin := "242124"
    static OuterSpace := "414A4C"
    static CafeNoir := "4B3621"

    ;; --- WHITES ---
    static White := "FFFFFF"
    static GhostWhite := "F8F8FF"
    static Ivory := "FFFFF0"
    static Snow := "FFFAFA"
    static FloralWhite := "FFFAF0"
    static AntiqueWhite := "FAEBD7"
    static Alabaster := "EDEAE0"
    static Pearl := "FBFCF8"
    static Eggshell := "F0EAD6"
    static Cornsilk := "FFF8DC"
    static Cream := "FFFDD0"
    static Beige := "F5F5DC"

    ;; --- GRAYS ---
    static Gray := "808080"
    static Silver := "C0C0C0"
    static Gainsboro := "DCDCDC"
    static LightGray := "D3D3D3"
    static DarkGray := "A9A9A9"
    static DimGray := "696969"
    static SlateGray := "708090"
    static LightSlateGray := "778899"
    static AshGray := "B2BEB5"
    static BattleshipGray := "848482"
    static Gunmetal := "2A3439"
    static Platinum := "E5E4E2"
    static CoolGray := "8C92AC"
    static CadetGray := "91A3B0"

    ;; --- YELLOWS ---
    static Yellow := "FFFF00"
    static LemonChiffon := "FFFACD"
    static CanaryYellow := "FFEF00"
    static Goldenrod := "DAA520"
    static Saffron := "F4C430"
    static Mustard := "FFDB58"
    static Flax := "EEDC82"
    static Citrine := "E4D00A"
    static Maize := "FBEC5D"
    static CyberYellow := "FFD300"
    static RoyalYellow := "FADA5E"
    static SelectiveYellow := "FFBA00"

    ;; --- CYANS ---
    static Cyan := "00FFFF"
    static Aqua := "00FFFF"
    static Aquamarine := "7FFFD4"
    ;static Turquoise := "40E0D0"
    static Celeste := "B2FFFF"
    static ElectricBlue := "7DF9FF"
    static TiffanyBlue := "0ABAB5"
    static RobinEggBlue := "00CCCC"
    static DarkCyan := "008B8B"
    static LightCyan := "E0FFFF"
    static PaleTurquoise := "AFEEEE"
    static DarkTurquoise := "00CED1"

    ;; --- MAGENTAS ---
    ;static Magenta := "FF00FF"
    static HotMagenta := "FF1DCE"
    static DarkMagenta := "8B008B"
    ;static Orchid := "DA70D6"
    ;static Fuchsia := "FF00FF"
    static SkyMagenta := "CF71AF"
    static SteelPink := "CC33CC"
    static RazzleDazzleRose := "FF33CC"
    static AfricanViolet := "B284BE"
    static AmaranthMagenta := "ED3CCA"
    static QuinacridoneMagenta := "8E3A59"

    ; Helper to get name from Hex
    static GetName(Hex) {
        Hex := StrReplace(StrUpper(Hex), "#", "")
        for Name, Value in this.OwnProps() {
            if (Value = Hex)
                return Name
        }
        return "Unknown"
    }
}

; --- Example Usage ---

; Accessing a property
; MsgBox("The hex for Steel Blue is: " . Colors.SteelBlue)

; ; Using the helper function
; MyHex := "72A0C1"
; ColorName := Colors.GetName(MyHex)

; if (ColorName = "Unknown")
;     return

; MsgBox("The name for " . MyHex . " is " . ColorName)