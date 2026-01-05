/** ### Description - GuiResizer Class
 * Use GuiResizer to automate the resizing of controls when a gui window is resized.
 * When assigning the event handler, use this: `MyGui.OnEvent('Size', resizer.Set)`.
 */ 
class GuiResizer {
    move := Map('w',[],'h',[])
    size := Map('w',[],'h',[])
    /** ### Description - GuiResizer.__New()
     * Create a new instance of GuiResizer.
     * @param {Object} g - The gui object that contains the controls.
     * @param {Array|Object|Map|String} params - A single object or Map object, or an array of objects
     * or Maps. Each object is a key-value container for the input parameters of the control assigned
     * to that object. The key-value pairs are:
     * {ctrl:control, x:multiplier, y:multiplier, w:multiplier, h:multiplier} where `control`
     * represents the Gui control object.
     * <br><br>
     * *Note* that you can also pass a string of control names
     * separated by a pipe ("|") as the `ctrl` property of an object, and each control included will
     * inherit their own object. So if multiple controls are using the same parameters, you can
     * include all of their names within the `ctrl` property. 
     * <br><br>
     * If the object has a `w` property, the control will be resized when the change in Gui size
     * occurs along the width. If the object has a `h` property, the control will be resized when
     * the change in Gui size occurs along the height. If the object has a `x` property, the
     * control will be moved when the change in Gui size occurs along the width. If the object has
     * a `y` property, the control will be moved when the change in Gui size occurs along the
     * height.
     * <br><br>
     * The `multiplier` is any positive number that will be multiplied by the change in
     * Gui size to determine the change in control position or size. Although it can be any number,
     * in most cases it should be a number n where 0 < n <= 1. Each of `x`, `y`, `w`, and `h` are
     * optional, but at least one should be submitted for each object. If not, the object will be ignored.
     * @param {Number} [interval=20] - The interval in milliseconds to wait before resizing the controls.
     * This is to avoid screen flickering.
     * @returns {Object} - Returns a new instance of GuiResizer.
     * ### Example
     * In the below example, note the various values used for each object in the array. When two
     * controls are next to each other, if both of them have a `w` value of 1, then they will
     * outgrow the gui window (because the total area would be increasing by 2 * the change in gui width).
     * So we must set the value to .5 for both edit2 and edit3 to keep them from outgrowing the window.
     * But since edit2 will be growing from the left of edit3, we also have to add an `x` value of 0.5
     * to make room for edit2.
     * 
     * For edit1 we left `w` as 1. This is because, generally, we don't want to resize buttons
     * when the gui resizes. They will stay the same width, and therefore contribute no additional
     * width to the area occupied by the controls. So edit1 gets to use the full additional width.
     * However, we have to move the buttons to make room, so we set `x` to 1 for each button.
     * 
     * The callback function to apply to the `g.OnEvent('Size', ...)` event is `resizer.Set`.
     * @example
     * g := Gui('+Resize +Owner')
     * g.Add('Edit', 'x10 y10 w400 h200 vedit')
     * g.Add('Button', 'x420 y10 w100 h25 vbtn1', 'Button 1')
     * g.Add('Button', 'w100 h25 vbtn2', 'Button 2')
     * g.Add('Button', 'w100 h25 vbtn3', 'Button 3')
     * g.Add('Edit', 'x10 y220 w200 h100 vedit2')
     * g.Add('Edit', 'x220 y220 w200 h100 vedit3')
     * params := [{ctrl:g['edit'],w:1,h:.5}, {ctrl:g['edit2'],w:.5,h:.5,y:.5}, {ctrl:g['edit3'],w:.5,h:.5,x:.5,y:.5}]
     * Loop 3
     *    params.push({ctrl:g['btn' A_Index],x:1})
     * resizer := GuiResizer(params)
     * g.OnEvent('Size', resizer.Set)
     * g.Show()
     * @
     * 
     * 
     */ 
    __New(g, params, interval := 20) {
        if Type(params) = 'Array' {
            for obj in params {
                _HandleParams_(obj)
            }
        } else
            _HandleParams_(params)
        g.GetPos(&gx, &gy, &gw, &gh)
        g.GetClientPos(, , , &ch)
        if ch
            this._initial := Map('w', gw, 'h', gh)
        else
            this.DefineProp('flag_notShown', {Value:true})
        this.DefineProp('Set', {Call: ObjBindMethod(this, '_Call')})
        this.interval := interval
        this.g := g

        _HandleParams_(obj) {
            if Type(obj) = 'Map'
                obj.DefineProp('__Get', {Call: ((self, key, *) => (self.Has(key) ? self.Get(key) : 0))})
            ctrl := obj.ctrl
            if Type(ctrl) = 'String' {
                split := StrSplit(ctrl, '|')
                for item in split {
                    clone := obj.Clone()
                    clone.ctrl := g[item]
                    __Handler(clone)
                }
            } else
                __Handler(obj)

            __Handler(obj) {
                if Type(obj) = 'Map' {
                    if obj.Has('x') {
                        obj.x := obj['x']
                        this.move['w'].push(obj)
                    }
                    if obj.Has('y') {
                        obj.y := obj['y']
                        this.move['h'].push(obj)
                    }
                    if obj.Has('w') {
                        obj.w := obj['w']
                        this.size['w'].Push(obj)
                    }
                    if obj.Has('h') {
                        obj.h := obj['h']
                        this.size['h'].Push(obj)
                    }
                } else if IsObject(obj) {
                    obj.DefineProp('__Get', {Call: ((*) => 0)})
                    obj.DefineProp('__Enum', {Call: ((self, key) => self.OwnProps())})
                    if obj.HasOwnProp('x')
                        this.move['w'].push(obj)
                    if obj.HasOwnProp('y')
                        this.move['h'].push(obj)
                    if obj.HasOwnProp('w')
                        this.size['w'].Push(obj)
                    if obj.HasOwnProp('h')
                        this.size['h'].Push(obj)
                } else
                    throw Error('The parameters must be objects or maps.', -1)
                for key, val in obj {
                    if key != 'ctrl' && !IsNumber(val)
                        throw Error('The values of properties ``x|y|w|h`` must be numbers.', -1)
                }
            }
        }
    }
    _Call(*) {
        if this.HasOwnProp('flag_notShown') {
            this.g.GetClientPos(, , , &ch)
            if ch {
                this.g.GetPos(, , &gw, &gh)
                this._initial := Map('w', gw, 'h', gh)
                this.DeleteProp('flag_notShown')
            }
        }
        if this.HasOwnProp('flag_timer') {
            if A_TickCount - this.flag_timer < this.interval {
                this.flag_timer := A_TickCount
                SetTimer this.Set, this.interval*-1 - 5
            } else
                this.Resize()
        } else {
            this.DefineProp('flag_timer', {Value: A_TickCount})
            SetTimer this.Set, this.interval*-1 - 5
        }
    }
    Resize() {
        this.g.GetPos(, , &gw, &gh)
        delta := Map('w', gw - this._initial['w'], 'h', gh - this._initial['h'])
        ctrls := []
        for dimension, container in this.move {
            if delta[dimension] {
                deltaX := (dimension = 'w' ? delta[dimension] : 0)
                deltaY := (dimension = 'h' ? delta[dimension] : 0)
                for obj in container {
                    ctrl := obj.ctrl
                    ctrl.Opt('-Redraw')
                    ctrl.GetPos(&x, &y)
                    ctrl.Move(x + deltaX*obj.x, y + deltaY*obj.y)
                    ctrls.push(ctrl)
                }
            }
        }
        for dimension, container in this.size {
            if delta[dimension] {
                deltaW := (dimension = 'w' ? delta[dimension] : 0)
                deltaH := (dimension = 'h' ? delta[dimension] : 0)
                for obj in container {
                    ctrl := obj.ctrl
                    ctrl.Opt('-Redraw')
                    ctrl.GetPos(, , &w, &h)
                    ctrl.Move(, , w + deltaW*obj.w, h + deltaH*obj.h)
                    ctrls.push(ctrl)
                }
            }
        }
        for ctrl in ctrls
            ctrl.opt('+Redraw')
        WinRedraw(this.g.hwnd)
        this._initial.Set(, , 'w', gw, 'h', gh)
        this.DeleteProp('flag_timer')
    }
}

/* example  */
#SingleInstance force
g := Gui('+Resize +Owner')
g.Add('Edit', 'x10 y10 w400 h200 vedit')
g.Add('Button', 'x420 y10 w100 h25 vbtn1', 'Button 1')
g.Add('Button', 'w100 h25 vbtn2', 'Button 2')
g.Add('Button', 'w100 h25 vbtn3', 'Button 3')
g.Add('Edit', 'x10 y220 w200 h100 vedit2')
g.Add('Edit', 'x220 y220 w200 h100 vedit3')

; object input
; params := [{ctrl:g['edit'],w:1,h:.5}, {ctrl:g['edit2'],w:.5,h:.5,y:.5}, {ctrl:g['edit3'],w:.5,h:.5,x:.5,y:.5}]
; Loop 3
;    params.push({ctrl:g['btn' A_Index],x:1})

; map input
; params := [Map('ctrl', g['edit'], 'w', 1,'h', .5), Map('ctrl', g['edit2'], 'w', .5,'h', .5,'y', .5), Map('ctrl', g['edit3'], 'w', .5,'h', .5,'x', .5,'y', .5)]
; Loop 3
;    params.push(Map('ctrl', g['btn' A_Index], 'x', 1))

; string input objects
params := [{ctrl:g['edit'],w:1,h:.5}, {ctrl:g['edit2'],w:.5,h:.5,y:.5}, {ctrl:g['edit3'],w:.5,h:.5,x:.5,y:.5}, {ctrl:'btn1|btn2|btn3',x:1}]

; string input maps
; params := [Map('ctrl', g['edit'], 'w', 1,'h', .5), Map('ctrl', g['edit2'], 'w', .5,'h', .5,'y', .5), Map('ctrl', g['edit3'], 'w', .5,'h', .5,'x', .5,'y', .5), Map('ctrl', 'btn1|btn2|btn3', 'x', 1)]

resizer := GuiResizer(g, params)
g.OnEvent('Size', resizer.Set)
g.Show()


/* example2 

g := Gui('+Resize +Owner')

myEdit1 :=g.Add('Edit', 'x10 y10 w400 h200')
edit1Params := {ctrl: myEdit1, w: 1, h: .5}

myBtn1 := g.Add('Button', 'x420 y10 w100 h25', 'Button 1')
btn1Params := {ctrl: myBtn1, x: 1}

myBtn2 := g.Add('Button', 'w100 h25', 'Button 2')
btn2Params := {ctrl: myBtn2, x: 1}

myBtn3 := g.Add('Button', 'w100 h25', 'Button 3')
btn3Params := {ctrl: myBtn3, x: 1}

myEdit2 := g.Add('Edit', 'x10 y220 w200 h100')
edit2Params := {ctrl: myEdit2, w: .5, h: .5, y: .5}

myEdit3 := g.Add('Edit', 'x220 y220 w200 h100')
edit3Params := {ctrl: myEdit3, x: .5, y: .5, w: .5, h: .5}

params := [edit1Params, edit2Params, edit3Params, btn1Params, btn2Params, btn3Params]
resizer := GuiResizer(g, params)
g.OnEvent('Size', resizer.Set)
g.Show()
