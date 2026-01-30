class ResizeableGui extends Gui {
	iMinWidth := 0
	iMinHeight := 0

	iWidth := 0
	iHeight := 0

	iResizers := []

	iDescriptor := false

	class Resizer {
		iGui := false

		Gui {
			Get {
				return this.iGui
			}
		}

		__New(resizeableGui) {
			this.iGui := resizeableGui
		}

		Initialize() {
		}

		CanResize(deltaWidth, deltaHeight) {
			return true
		}

		Resize(deltaWidth, deltaHeight) {
		}
	}

	class ControlResizer extends ResizeableGui.Resizer {
		iRule := false
		iControl := false

		iOriginalX := 0
		iOriginalY := 0
		iOriginalWidth := 0
		iOriginalHeight := 0

		Control {
			Get {
				return this.iControl
			}
		}

		Rule {
			Get {
				return this.iRule
			}
		}

		OriginalX {
			Get {
				return this.iOriginalX
			}
		}

		OriginalY {
			Get {
				return this.iOriginalY
			}
		}

		OriginalWidth {
			Get {
				return this.iOriginalWidth
			}
		}

		OriginalHeight {
			Get {
				return this.iOriginalHeight
			}
		}

		__New(resizeableGui, control, rule) {
			this.iControl := control
			this.iRule := rule

			super.__New(resizeableGui)
		}

		Initialize() {
			local x, y, w, h

			ControlGetPos(&x, &y, &w, &h, this.Control)

			this.iOriginalX := x
			this.iOriginalY := y
			this.iOriginalWidth := w
			this.iOriginalHeight := h
		}

		CanResize(deltaWidth, deltaHeight) {
			return !!this.Rule
		}

		Resize(deltaWidth, deltaHeight) {
			local x := this.OriginalX
			local y := this.OriginalY
			local w := this.OriginalWidth
			local h := this.OriginalHeight
			local ignore, part, variable, horizontal

			for ignore, part in string2Values(";", this.Rule) {
				part := string2Values(":", part)
				variable := part[1]

				if (variable = "Width")
					variable := "w"
				else if (variable = "Height")
					variable := "h"

				horizontal := ((variable = "x") || (variable = "w"))

				switch part[2], false {
					case "Move":
						%variable% += (horizontal ? deltaWidth : deltaHeight)
					case "Move/2":
						%variable% += Round((horizontal ? deltaWidth : deltaHeight) / 2)
					case "Grow":
						%variable% += (horizontal ? deltaWidth : deltaHeight)
					case "Grow/2":
						%variable% += Round((horizontal ? deltaWidth : deltaHeight) / 2)
					case "Center":
						if horizontal
							x := Round((this.Gui.Width / 2) - (w / 2))
						else
							y := Round((this.Gui.Height / 2) - (h / 2))
				}
			}

			ControlMove(x, y, w, h, this.Control)

			this.Control.Redraw()
		}
	}

	Descriptor {
		Get {
			return this.iDescriptor
		}

		Set {
			return (this.iDescriptor := value)
		}
	}

	MinWidth {
		Get {
			return this.iMinWidth
		}
	}

	MinHeight {
		Get {
			return this.iMinHeight
		}
	}

	Width {
		Get {
			return this.iWidth
		}
	}

	Height {
		Get {
			return this.iHeight
		}
	}

	Resizers {
		Get {
			return this.iResizers
		}
	}

	__New(arguments*) {
		super.__New(arguments*)

		this.Opt("+Resize -MaximizeBox")

		this.OnEvent("Size", this.Resize)
	}

	Show(arguments*) {
		local x, y, width, height

		super.Show(arguments*)

		WinGetPos(&x, &y, &width, &height, this)

		this.iMinWidth := width
		this.iMinHeight := height
		this.iWidth := width
		this.iHeight := height

		for ignore, resizer in this.Resizers
			resizer.Initialize()
	}

	AddResizer(resizer) {
		this.Resizers.Push(resizer)
	}

	DefineResizeRule(control, rule) {
		this.AddResizer(ResizeableGui.ControlResizer(this, control, rule))
	}

	Resize(minMax, width, height) {
		local descriptor := this.Descriptor
		local x, y, w, h, settings

		if (minMax = "Initialize") {
			WinGetPos(&x, &y, &w, &h, this)

			this.iWidth := width
			this.iHeight := height

			WinMove(x, y, width, height, this)
		}
		else {
			if !this.Width
				return

			WinGetPos(&x, &y, &w, &h, this)

			width := w
			height := h

			if ((width < this.iMinWidth) || (height < this.iMinHeight)) {
				this.iWidth := this.MinWidth
				this.iHeight := this.MinHeight

				WinMove(x, y, this.MinWidth, this.MinHeight, this)

				this.ControlsResize(this.MinWidth, this.MinHeight)
			}
			else if ((this.Resizers.Length = 0) || !this.ControlsCanResize(width, height)) {
				if (this.Width && this.Height)
					WinMove(x, y, this.Width, this.Height, this)
			}
			else {
				this.iWidth := width
				this.iHeight := height

				this.ControlsResize(width, height)

				WinRedraw(this)
			}
		}
	}

	ControlsCanResize(width, height) {
		local ignore, resizer

		for ignore, resizer in this.Resizers
			if !resizer.CanResize(width - this.MinWidth, height - this.MinHeight)
				return false

		return true
	}

	ControlsResize(width, height) {
		local ignore, resizer

		for ignore, resizer in this.Resizers
			resizer.Resize(width - this.MinWidth, height - this.MinHeight)
	}
}