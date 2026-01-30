
#Requires AutoHotkey 2+

#Include ReSizeableGui.ahk

    g := ResizeableGui()

		this.iWindow := g

		g.Opt("-Border -Caption +0x800000")
		g.BackColor := "D0D0D0"

		g.SetFont("s10 Bold", "Arial")

		control := g.Add("Text", "w1184 Center", translate("Modular Simulator Controller System"))
		control.OnEvent("Click", moveByMouse.Bind(g, "Race Reports"))
		g.DefineResizeRule(control, "X:Center")

		g.SetFont("s9 Norm", "Arial")
		g.SetFont("Italic Underline", "Arial")

		control := g.Add("Text", "x508 YP+20 w184 cBlue Center", translate("Race Reports"))
		control.OnEvent("Click", openDocumentation.Bind(g, "https://github.com/SeriousOldMan/Simulator-Controller/wiki/Virtual-Race-Strategist#race-reports"))
		g.DefineResizeRule(control, "X:Center")

		g.DefineResizeRule(g.Add("Text", "x8 yp+30 w1200 0x10"), "W:Grow")

		g.SetFont("s8 Norm", "Arial")

		g.Add("Text", "x16 yp+10 w70 h23 +0x200 Section", translate("Simulator"))

		simulators := this.getSimulators()

		simulator := ((simulators.Length > 0) ? 1 : 0)

		g.Add("DropDownList", "x90 yp w180 Choose" . simulator . " vsimulatorDropDown", simulators).OnEvent("Change", chooseSimulator)

		if (simulator > 0)
			simulator := simulators[simulator]
		else
			simulator := false

		g.Add("Text", "x16 yp+24 w70 h23 +0x200", translate("Car"))
		g.Add("DropDownList", "x90 yp w180 vcarDropDown").OnEvent("Change", chooseCar)

		g.Add("Text", "x16 yp24 w70 h23 +0x200", translate("Track"))
		g.Add("DropDownList", "x90 yp w180 vtrackDropDown").OnEvent("Change", chooseTrack)

		g.Add("Text", "x16 yp+26 w70 h23 +0x200", translate("Races"))

		this.iRacesListView := g.Add("ListView", "x90 yp-2 w180 h252 BackgroundD8D8D8 -Multi -LV0x10 AltSubmit NoSort NoSortHdr", collect(["Date", "Time", "Duration", "Starting Grid"], translate))
		this.iRacesListView.OnEvent("Click", chooseRace)
		g.DefineResizeRule(this.iRacesListView, "H:Grow")

		g.Add("Button", "x62 yp+205 w23 h23 vreloadReportsButton").OnEvent("Click", reloadRaceReports)
		setButtonIcon(g["reloadReportsButton"], kIconsDirectory . "Renew.ico", 1)
		g.DefineResizeRule(g["reloadReportsButton"], "Y:Move")

		g.Add("Button", "x62 yp+24 w23 h23 vdeleteReportButton").OnEvent("Click", deleteRaceReport)
		setButtonIcon(g["deleteReportButton"], kIconsDirectory . "Minus.ico", 1)
		g.DefineResizeRule(g["deleteReportButton"], "Y:Move")

		g.DefineResizeRule(g.Add("Text", "x16 yp+30 w70 h23 +0x200", translate("Info")), "Y:Move")
		g.Add("ActiveX", "x90 yp-2 w180 h170 Border vinfoViewer", "shell.explorer").Value.Navigate("about:blank")
		g.DefineResizeRule(g["infoViewer"], "Y:Move")

		g.Add("Text", "x290 ys w40 h23 +0x200", translate("Report"))
		g.Add("DropDownList", "x334 yp w120 AltSubmit Disabled Choose0 vreportsDropDown", collect(kRaceReports, translate)).OnEvent("Change", chooseReport)

		g.Add("Button", "x1177 yp w23 h23 vreportSettingsButton").OnEvent("Click", reportSettings)
		setButtonIcon(g["reportSettingsButton"], kIconsDirectory . "Report Settings.ico", 1)

		g.DefineResizeRule(g["reportSettingsButton"], "X:Move")

		g.Add("ActiveX", "x290 yp+24 w910 h475 Border vchartViewer", "shell.explorer").Value.Navigate("about:blank")
		g.DefineResizeRule(g["chartViewer"], "W:Grow;H:Grow")

		this.iReportViewer := RaceReportViewer(g, g["chartViewer"].Value, g["infoViewer"].Value)

		this.loadSimulator(simulator, true)

		g.DefineResizeRule(g.Add("Text", "x8 y574 w1200 0x10"), "Y:Move;W:Grow")

		control := g.Add("Button", "x574 y580 w80 h23", translate("Close"))
		control.OnEvent("Click", closeReports)
		g.DefineResizeRule(control, "X:Center;Y:Move")

		g.AddResizer(RaceReports.ReportResizer(g))