; Script to benchmark and test GDip / CGdipSnapshot

#SingleInstance, force
#include <CGdipSnapshot>
global snap1 := new CGDipSnapshot(1,1,1,1)
global snap2a := new CGDipSnapshot(1,1,10,10)
global snap2b := new CGDipSnapshot(1,1,10,10)
snap2b.TakeSnapshot()
global snap3 := new CGDipSnapshot(1,1,100,100)

; Check basic AHK performance
QPX.Add("AHK_Pixel_Get_Color")
; Check how long lib takes to grab a 1x1 snapshot with GDI
QPX.Add("GDI_Take_Snap_1x1")
; Check how long it takes to get pixel from the snapshot
QPX.Add("GDI_PixelSnap")
; Repeat - does cache work?
QPX.Add("GDI_PixelSnap")
; Re-Do single pixel test, to see how long it takes to flush old bitmap and get a new one
QPX.Add("GDI_Take_Snap_1x1")
; Repeat color grabs
QPX.Add("GDI_PixelSnap")
QPX.Add("GDI_PixelSnap")
; See how long it takes to grab a 10x10 snapshot
QPX.Add("GDI_Take_Snap_10x10")
; See how long it takes to grab a 100x100 snapshot
QPX.Add("GDI_Take_Snap_100x100")
; Compare two objects (note: same image, different objs, so no cache hit at all in first pass)
QPX.Add("GDI_Compare_Snap_10x10")
; Repeat test - should be healthy cache accleration
QPX.Add("GDI_Compare_Snap_10x10")
; Re-check
QPX.Add("GDI_Compare_Snap_10x10")
; Clear the cache, but keep the bitmap.
QPX.Add("GDI_Reset_Snaps")
; Repeat compare test - should be no cache hit
QPX.Add("GDI_Compare_Snap_10x10")
; Repeat - cache should hit again
QPX.Add("GDI_Compare_Snap_10x10")

QPX.Test(1)

GDI_Take_Snap_1x1() {
	snap1.TakeSnapshot()
}

GDI_Take_Snap_10x10() {
	snap2a.TakeSnapshot()
}

GDI_Take_Snap_100x100() {
	snap3.TakeSnapshot()
}

GDI_PixelSnap(){
	return snap1.PixelSnap[0,0].rgb
}

GDI_Compare_Snap_10x10(){
	return snap2a.Compare(snap2b)
}

GDI_Reset_Snaps(){
	; not a benchmark, just resetting between benchmarks
	snap2a._PixelCache := [[],[]]
	snap2b._PixelCache := [[],[]]
}

AHK_Pixel_Get_Color(){
	PixelGetColor, ov, 1,1, RGB
	return ov
}

Class QPX {	; Tests how fast functions and/or subroutines run and diplays results in a window. By Learning one. Uses QPX function by SKAN - thank you!
	static FuncRef := [], FuncParams := [], SubNames := []	; collections of: function references, function parameters, subroutine names
	static AutoInit := QPX.__New()	; AutoInit is evaluated before the auto-execute section (Static Initializer), and it constructs QPX object.
	__New() {
		w := 400, h := 250
		Gui, New, +HwndhGui
		Gui %hGui%:Font, , Courier New
		Gui %hGui%:Add, Text, x22 y22 w22 h22 Hide hwndhgDefocuser
		Gui %hGui%:Add, Edit, % "x2 y2 w" (w-4)/2 " h" h-6 " hwndhgEdit1"
		Gui %hGui%:Add, Edit,  % "x" w/2 " y2 w" (w-4)/2 " h" h-6 " hwndhgEdit2"
		Gui %hGui%:Show, % "w" w " h" h " Hide", QPC test
		this.hGui := hGui, this.hgDefocuser := hgDefocuser, this.hgEdit1 := hgEdit1, this.hgEdit2 := hgEdit2	; store
	}
	Add(params*) {	; Adds a function or a subroutine to the test collection.
	/*
	This method automatically detects are you adding a function or a subroutine to the test collection. If you are adding a :
	a)	subroutine, 1. parameter is a subroutine name. Example: QPX.Add("MySubroutine")
	b)	function, 1. parameter is a function name, and other parameters (optional) are that function's parameters. If parameter has expressions, all of them are evaluated in the moment when they are added to the collection (not in the moment when Test method is called). Example1: QPX.Add("MyFunction") Example2: QPX.Add("AnotherFunction", "param1", "param2", "param3")
	If you have a function and a subroutine with the same name in your code, and you are adding it to the test collection, function will be added (not subroutine).
	*/		
		if (IsFunc(params.1) > 0) {	; a function
			this.FuncRef.Insert(Func(params.1))	; convert function name to function reference and store it in this.FuncRef
			NewParams := []
			For k,v in params
			{
				if (k != 1)	; 1. param is the function name, other are function params
					NewParams.Insert(v)
			}
			this.FuncParams.Insert(NewParams)	; store function parameters
			;this.FuncRef.1.(this.FuncParams.1*)	; call 1 function in collection with its parameters
			;MsgBox % this.FuncRef.2.(this.FuncParams.2*)	; call 2 function in collection with its parameters and display return value in MsgBox
		}
		else if (IsLabel(params.1) > 0) {	; a subroutine
			this.SubNames.Insert(params.1)	; store subroutine name
			;Gosub, % this.SubNames.1	; execute 1. subroutine in collection
		}
	}
	Remove(FuncOrSubName="") {	;  If FuncOrSubName is blank, it removes all functions and subroutines from the test collection, otherwise, it removes specified func or sub.
		if (FuncOrSubName= "") {	; remove all functions and subs from the collection - overwrite with blank obj
			this.FuncRef := [], this.FuncParams := [], this.SubNames := []	; WRONG would be: this.FuncRef := "", this.FuncParams := "", this.SubNames := ""
		}
		else {	; remove specified func or sub from collection
			if (IsFunc(FuncOrSubName) > 0) {	; function
				For k,v in this.FuncRef			; v = function reference
				{
					if (v.Name = FuncOrSubName) {	; we want to remove this item
						ToRemove := k
						break
					}
				}
				if (ToRemove != "")
					this.FuncRef.Remove(ToRemove), this.FuncParams.Remove(ToRemove)	; remove from both func collections!
			}
			else if (IsLabel(FuncOrSubName) > 0) {	; subroutine
				For k,v in this.SubNames			; v = subroutine name
				{
					if (v = FuncOrSubName) {	; we want to remove this item
						ToRemove := k
						break
					}
				}
				if (ToRemove != "")
					this.SubNames.Remove(ToRemove)	; remove from sub collection
			}
		}
	}
	Test(NumberOfIterations=10, Sleep=10) {	; Tests functions and/or subroutines in test collection and displays results in a window. Left edit = Summary. Right edit = Details.
		oElapsedTimesF := []	; collection of elapsed times for all functions. Each item in collection is a sub-object (simple array) which consist of all elapsed times for that function
		oElapsedTimesS := []	; collection of elapsed times for all subroutines. Each item in collection is a sub-object (simple array) which consist of all elapsed times for that subroutine
		; oElapsedTimesF.3 = simple array of elapsed times for 3. function
		; oElapsedTimesF.3.4 = get number which represents 4. elapsed time in 3. function
		
		hGui := this.hGui
		
		if (this.FuncRef.MaxIndex() = "" and this.SubNames.MaxIndex() = "") {	; there's nothing in test collection
			Gui %hGui%:+OwnDialogs
			MsgBox,, QPC test, There is nothing to test. Please use Add method to add functions or subroutines you want to test.
			return
		}
		For k,v in this.FuncRef	; create item (sub-object) for each function in collection which will be populated with elapsed times
			oElapsedTimesF.Insert([])
		For k,v in this.SubNames	; create item (sub-object) for each subroutine in collection which will be populated with elapsed times
			oElapsedTimesS.Insert([])	
		FastestAve := 1000000000000	; here we'll store the fastest average run time of all items in test collection
		
		GuiControl, % this.hGui ":+ReadOnly" , % this.hgEdit1, ; Summary
		GuiControl, % this.hGui ":+ReadOnly" , % this.hgEdit2, ; Details
		Gui %hGui%:Show
		
		Loop, % NumberOfIterations			; test for specified number of iterations
		{
			For k,v in this.FuncRef			; test each function. v = function reference
			{
				this.QPX(1)					; Start - Initialise Counter
				v.(this.FuncParams[k]*)		; call a function (by reference) with its parameters. To see return value each time: MsgBox % v.(this.FuncParams[k]*)
				ElapsedTime := this.QPX(0)	; Stop, get time consumed and reset internal vars
				
				oElapsedTimesF[k].Insert(ElapsedTime)	; insert elapsed time for this function
				Sleep, % Sleep				; Good: more objective and accurate results + anti high CPU load. Bad: test lasts longer...
			}
			For k,v in this.SubNames		; test each subroutine. v = subroutine name
			{
				this.QPX(1)					; Start - Initialise Counter
				Gosub, % v					; execute subroutine in collection
				ElapsedTime := this.QPX(0)	; Stop, get time consumed and reset internal vars
				
				oElapsedTimesS[k].Insert(ElapsedTime)	; insert elapsed time for this subroutine
				Sleep, % Sleep				; Good: more objective and accurate results + anti high CPU load. Bad: test lasts longer...
			}
			
			WinSetTitle, % "ahk_id " this.hGui,, % "QPC test - " A_Index "/" NumberOfIterations " iterations"
		}
		
		For k,v in oElapsedTimesF	; process function test results. v = reference to simple array of elapsed times for current function
		{
			Min := 1000000000000, Max := 0, Tot := 0
			For k2,v2 in v			; v2 = current elapsed time
			{
				if (v2 < Min)	; new minimum
					Min := v2
				if (v2 > Max)	; new maximum
					Max := v2
				Tot += v2		; add time to a total time elapsed
			}
			Ave	:= Tot/NumberOfIterations	; get average
			if (Ave < FastestAve)	; new fastest average run time of all items in test collection
				FastestAve := Ave, FastestAveItemName := this.FuncRef[k].Name
			
			;=== Get percentage for minimum and maximum relative to average run time, format, alignment ===
			PercMin := this.FormatPerc(Min/ave*100), PercAve := this.FormatPerc(100), PercMax := this.FormatPerc(Max/ave*100)
			
			Summary .= this.FuncRef[k].Name "`n" Ave "`n"
			Details .= this.FuncRef[k].Name "`nMin: " Min PercMin "`nAve: " Ave PercAve "`nMax: " Max PercMax "`nTot: " Tot "`n`n"
		}
		For k,v in oElapsedTimesS	; process subroutine test results. v = reference to simple array of elapsed times for current subroutine
		{
			Min := 1000000000000, Max := 0, Tot := 0
			For k2,v2 in v			; v2 = current elapsed time
			{
				if (v2 < Min)	; new minimum
					Min := v2
				if (v2 > Max)	; new maximum
					Max := v2
				Tot += v2		; add time to a total time elapsed
			}
			Ave	:= Tot/NumberOfIterations	; get average
			if (Ave < FastestAve)	; new fastest average run time of all items in test collection
				FastestAve := Ave, FastestAveItemName := this.SubNames[k]
			
			;=== Get percentage for minimum and maximum relative to average run time, format, alignment ===
			PercMin := this.FormatPerc(Min/ave*100), PercAve := this.FormatPerc(100), PercMax := this.FormatPerc(Max/ave*100)
			
			Summary .= this.SubNames[k] "`n" Ave "`n"
			Details .= this.SubNames[k] "`nMin: " Min PercMin "`nAve: " Ave PercAve "`nMax: " Max PercMax "`nTot: " Tot "`n`n"
		}
		Summary := RTrim(Summary, "`n"), Details := RTrim(Details, "`n")
		Summary := this.RefineSummary(Summary, FastestAve, FastestAveItemName)
		
		GuiControl, % this.hGui ":" , % this.hgEdit1, % Summary
		GuiControl, % this.hGui ":" , % this.hgEdit2, % Details
		GuiControl, % this.hGui ":-ReadOnly" , % this.hgEdit1,	; Summary
		GuiControl, % this.hGui ":-ReadOnly" , % this.hgEdit2,	; Details
		GuiControl, % this.hGui ":Focus", % this.hgDefocuser	; Defocus edit control + anti "all text in edit is selected" measure. Looks better :)
		Gui %hGui%:Show, , % "QPC test results - " NumberOfIterations " iterations"	; show results
	}
	
	;=== Private methods ===
	RefineSummary(Summary, FastestAve, FastestAveItemName) {	; Get percentage for each average run time relative to fastest average run time for all items in test collection, mark fastest item, indentation, and write that to summary string
		FastestAve := Trim(FastestAve)	; although there is nothing to trim, for some strange reason this has to be done
		;ToolTip % "x" FastestAve "x"
		Indent := "   "
		Loop, parse, Summary, `n, `r
		{
			if (Mod(A_Index, 2) = 1) {	; odd number (neparni broj) = Item name. Exa: "TestFunc1"
				if (A_LoopField = FastestAveItemName)	; mark this item as fastest
					NewSummary .= A_LoopField " <<`n"
				else
					NewSummary .= A_LoopField "`n"
			}
			else						; even number (parni broj) = Item's average run time. Exa: "0.001161"
				NewSummary .= Indent A_LoopField this.FormatPerc(A_LoopField/FastestAve*100) "`n"
		}
		return RTrim(NewSummary, "`n")
	}
	FormatPerc(PercentWithoutSign) {	; round number, prepend some spaces for alignment and add percent sign. Exa: in: "83.134231" out: "   83%"
		Percent := Round(PercentWithoutSign) "`%"
		WantedStrLen := 6, PerStrLen := StrLen(Percent)
		if (PerStrLen < WantedStrLen) {
			Loop % WantedStrLen - PerStrLen
				SpaceIndent .= A_Space
		}
		else
			SpaceIndent := A_Space
		return SpaceIndent Percent
	}
	QPX( N=0 ) {       ;  Wrapper for  QueryPerformanceCounter()by SKAN  | CD: 06/Dec/2009
		Static F,A,Q,P,X  ;  www.autohotkey.com/forum/viewtopic.php?t=52083 | LM: 10/Dec/2009
		If ( N && !P )
		Return  DllCall("QueryPerformanceFrequency",Int64P,F) + (X:=A:=0)
			+ DllCall("QueryPerformanceCounter",Int64P,P)
		DllCall("QueryPerformanceCounter",Int64P,Q), A:=A+Q-P, P:=Q, X:=X+1
		Return ( N && X=N ) ? (X:=X-1)<<64 : ( N=0 && (R:=A/X/F) ) ? ( R + (A:=P:=X:=0) ) : 1
	}
}