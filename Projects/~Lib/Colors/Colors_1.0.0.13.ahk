; TITLE  :  Colors v1.0.0.13
; SOURCE :  Gemini and https://www.color-meanings.com/
; LICENSE:  The Unlicense, see https://unlicense.org
; PURPOSE:  Colors for Guis and Controls
; USAGE  :
; NOTES  :

/*
    TODO:
*/

#Requires AutoHotkey v2+

/*
    Version: 1.0.0.13
*/

class Colors {

    ;; --- ~ MY FAVORITES ~ ---
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

    static MyGui                := this.AirSuperiorityBlue

    static Gold                 := "FFD700"
    static SourLemon            := "FFEAA7"
    static Windstorm            := "6B9BC2"
    static WedgeWood            := "4E7F9E"

    static MyCtrl               := this.SourLemon

    ;; --- BLACKS ---
    static Black := "000000"
    static CafeNoir := "4B3621"
    static Charcoal := "36454F"
    static Ebony := "555D50"
    static Jet := "343434"
    static Licorice := "1A1110"
    static Midnight := "2B2B2B"
    static Obsidian := "080808"
    static Oil := "3B3131"
    static Onyx := "353839"
    static OuterSpace := "414A4C"
    static Raisin := "242124"

    ;; --- BLUES ---
    static Azure := "007FFF"
    static Blue := "0000FF"
    static Cerulean := "007BA7"
    static CornflowerBlue := "6495ED"
    static MidnightBlue := "191970"
    static NavyBlue := "000080"
    static RoyalBlue := "4169E1"
    static SkyBlue := "87CEEB"
    static Teal := "008080"

    ;; --- CYANS ---
    static Aqua := "00FFFF"
    static Aquamarine := "7FFFD4"
    static Celeste := "B2FFFF"
    static Cyan := "00FFFF"
    static DarkCyan := "008B8B"
    static DarkTurquoise := "00CED1"
    static ElectricBlue := "7DF9FF"
    static LightCyan := "E0FFFF"
    static PaleTurquoise := "AFEEEE"
    static RobinEggBlue := "00CCCC"
    static TiffanyBlue := "0ABAB5"
    static Turquoise := "40E0D0"

    ;; --- GRAYS ---
    static AshGray := "B2BEB5"
    static BattleshipGray := "848482"
    static CadetGray := "91A3B0"
    static CoolGray := "8C92AC"
    static DarkGray := "A9A9A9"
    static DimGray := "696969"
    static Gainsboro := "DCDCDC"
    static Gray := "808080"
    static Gunmetal := "2A3439"
    static LightGray := "D3D3D3"
    static LightSlateGray := "778899"
    static Platinum := "E5E4E2"
    static Silver := "C0C0C0"
    static SlateGray := "708090"

    ;; --- GREENS ---
    static Emerald := "50C878"
    static ForestGreen := "228B22"
    static Green := "008000"
    static JungleGreen := "29AB87"
    static KellyGreen := "4CBB17"
    static Lime := "00FF00"
    static MintGreen := "98FB98"
    static Olive := "808000"
    static SageGreen := "9DC183"
    static SeaGreen := "2E8B57"

    ;; --- MAGENTAS ---
    static AfricanViolet := "B284BE"
    static AmaranthMagenta := "ED3CCA"
    static DarkMagenta := "8B008B"
    static Fuchsia := "FF00FF"
    static HotMagenta := "FF1DCE"
    static Magenta := "FF00FF"
    static Orchid := "DA70D6"
    static QuinacridoneMagenta := "8E3A59"
    static RazzleDazzleRose := "FF33CC"
    static SkyMagenta := "CF71AF"
    static SteelPink := "CC33CC"

    ;; --- ORANGES ---
    static AlloyOrange := "C35214"
    static Amber := "FFBF00"
    static Apricot := "FBCEB1"
    static Coral := "FF7F50"
    static DarkOrange := "FF8C00"
    static Orange := "FFA500"
    static Peach := "FFE5B4"
    static Pumpkin := "FF7518"
    static Tangerine := "F28500"
    static VividOrange := "FF5E0E"

    ;; --- PURPLES & PINKS ---
    static Amaranth := "E52B50"
    static DeepPink := "FF1493"
    static HotPink := "FF69B4"
    static Lavender := "E6E6FA"
    static Pink := "FFC0CB"
    static Plum := "DDA0DD"
    static Purple := "800080"

    ;; --- REDS ---
    static BarnRed := "7C0A02"
    static ChiliRed := "C21807"
    static Crimson := "B80F0A"
    static DarkRed := "8B0000"
    static FireBrick := "B22222"
    static ImperialRed := "ED2939"
    static IndianRed := "CD5C5C"
    static Red := "FF0000"
    static Scarlet := "FF2400"
    static Tomato := "FF6347"

    ;; --- WHITES ---
    static Alabaster := "EDEAE0"
    static AntiqueWhite := "FAEBD7"
    static Beige := "F5F5DC"
    static Cornsilk := "FFF8DC"
    static Cream := "FFFDD0"
    static Eggshell := "F0EAD6"

    ;; --- YELLOWS ---
    static CanaryYellow := "FFEF00"
    static Citrine := "E4D00A"
    static CyberYellow := "FFD300"
    static Flax := "EEDC82"
    static Goldenrod := "DAA520"
    static LemonChiffon := "FFFACD"
    static Maize := "FBEC5D"
    static Mustard := "FFDB58"
    static RoyalYellow := "FADA5E"
    static Saffron := "F4C430"
    static SelectiveYellow := "FFBA00"
    static Yellow := "FFFF00"

    ;; FUNCTIONS
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