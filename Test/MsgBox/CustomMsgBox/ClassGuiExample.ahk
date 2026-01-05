
#Requires AutoHotkey v2

;ahkv2 mvc-model-view-controller-pattern 
obgui := gui()
progObj := Program()
progObj.main(&obgui)

class sModel {
	mtn := "" 
	func() {
		this.mtn := "metin"
	}
}

class sView {
	loadControls(&g) { 
		g.opt("+alwaysontop")
		g.ed1 := g.add("edit","ved1 r3 w200","ed1")
		g.btn1 := g.add("button","vbtn1","btn1") 
		
		g.btn1.onEvent("click", btn1_click)
		g.btn2 := g.add("button","vbtn2","btn2") 
		g.btn2.onEvent("click", btn2_click)
		; this.showGui(g)
		btn1_click(*) {
			this.obCtrlr.btn1_listener(&g)
			
		}
		btn2_click(*) {
			this.obCtrlr.btn2_listener(&g)
		}
	}
	
	
	showGui(&g) {
		
		this.loadControls(&g)
		g.show()
	}
	
	addListener(&Controller) {
		this.obCtrlr := Controller
	}
}

class sController {
	oModel := sModel()
	oView := sView()
	baslat() {
		this.oView.addListener(&this)
	} 
	
	btn1_listener(&g) {
		this.oModel.func() 
		g.ed1.value := this.oModel.mtn 
	}
	btn2_listener(&g) {
		this.oModel.func() 
		g.ed1.value := this.oModel.mtn . "-btn2" 
	}
}

class Program {
	oController := sController()
	main(&g) {
		this.oController.baslat()
		this.oController.oView.showGui(&g)
		
	}
}

