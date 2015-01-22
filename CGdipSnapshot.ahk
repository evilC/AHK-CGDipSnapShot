/*
CGDipSnapShot.ahk
By evilc@evilc.com

Use Gdip_All.ahk from this page: http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
Place it in C:\Program Files\Autohotkey\Lib (Create Lib folder if it does not exist)

ToDo:
* Compare to compare to this (only accept one other colour as arg)
* "Private" stuff to underscore prefix

*/
#include <gdip_all>

Class CGDipSnapShot {
	pToken := 0
	pBitmap := 0 							; bitmap image
	hBitmap := 0 							; HWND for bitmap?
	Coords := {x: 0, y: 0, w: 0, h: 0} 		; Coords of snapshot area relative to screen
	_SnapshotTaken := 0
	_NegativeValue := {rgb: -1, r: -1, g: -1, b: -1}
	_PixelCache := [[],[]]

	; === User Functions ==================================================================================================================================
	; Intended for use by people using the class.

	; Take a new Snapshot
	TakeSnapshot(){
		this._ResetSnapshot()
		this.pBitmap := GDIP_BitmapFromScreen(this.Coords.x "|" this.Coords.y "|" this.Coords.w "|" this.Coords.h)
		this._SnapshotTaken := 1
		return
	}

	; Show the Snapshot in the specified HWND.
	; Declare a regular AHK GUI Textbox like so:
	; Gui, Add, Text, 0xE x5 y5 w200 h200 hwndSnapshotPreview
	; Then ShowSnapshot(SnapshotPreview) to show the snapshot in that GUI item
	ShowSnapshot(hwnd){
		if (!this._SnapshotTaken){
			this.TakeSnapshot()
		}
		if (this.hBitmap){
			; Delete old hwnd
			DeleteObject(this.hBitmap)
		}
		this.hBitmap := Gdip_CreateHBITMAPFromBitmap(this.pBitmap)
		SendMessage, 0x172, 0, % this.hBitmap, , % "ahk_id " hwnd
		return
	}

	; Save snapshot to file
	; Supported extensions are: .BMP,.DIB,.RLE,.JPG,.JPEG,.JPE,.JFIF,.GIF,.TIF,.TIFF,.PNG
	SaveSnapshot(filename, quality := 100){
		if (!this._SnapshotTaken){
			this.TakeSnapshot()
		}
		return Gdip_SaveBitmapToFile(this.pBitmap, filename, quality)
	}

	; Move / Resize the Snapshot after creation
	; Pass an object containing which properties you wish to set.
	; eg to set only x and h to 0, but leave y and w the same, pass {x: 0, h:0}
	Set(obj){
		was_set := 0
		for key, value in Obj {
			if (key in x,y,w,h){
				was_set++
				this.Coords[key] := value
			}
		}
		; If moved or resized, reset the Pixel Cache
		if (was_set){
			this._ResetSnapshot()
		}
	}
	
	; Compares r/g/b integer objects, with a tolerance
	; returns true or false
	Compare(c1, c2, tol := 20) {
		if (!this._SnapshotTaken){
			this.TakeSnapshot()
		}
		diff := Abs( c1.r - c2.r ) "," Abs( c1.g - c2.g ) "," Abs( c1.b - c2.b )
		sort diff,N D,

		StringSplit, diff, diff, `,
		return diff%diff0% < tol
	}

	; Returns the Difference between two colors
	Diff(c1,c2){
		if (!this._SnapshotTaken){
			this.TakeSnapshot()
		}
		diff := Abs( c1.r - c2.r ) "," Abs( c1.g - c2.g ) "," Abs( c1.b - c2.b )
		sort diff,N D,

		StringSplit, diff, diff, `,
		return diff%diff0% < tol
	}
	
	; Converts Screen coords to Snapshot coords
	ScreenToSnap(x,y){
		return {x: x - this.Coords.x, y: y - this.Coords.y}
	}

	; Returns true if the snapshot coordinates are valid (eg x not bigger than width)
	; NOT for telling if a screen coord is inside the snapshot
	IsSnapCoord(xpos,ypos){
		if (xpos < 0 || xpos > this.Coords.w || ypos < 0 || ypos > this.Coords.h){
			return 0
		}
		return 1
	}
	
	; Is a screen coord inside the snapshot area?
	IsInsideSnap(xpos,ypos){
		if (xpos < this.Coords.x || ypos < this.Coords.y || xpos > (this.Coords.x + this.Coords.w) || ypos > (this.Coords.y + this.Coords.h) ){
			return 0
		}
		return 1
	}
	
	; ===== Available for End-user use, but not advised (Use alternatives) ===================================================
	
	; Gets colour of a pixel relative to the screen (As long as it is inside the snapshot)
	; Returns -1 if asked for a pixel outside the snapshot
	; Advise use of PixelScreen[] Array instead of this function, as results are cached
	PixelGetColor(xpos,ypos){
		; Return RGB value of -1 if outside snapshot area
		if (!this.IsInsideSnap(xpos,ypos)){
			return this._NegativeValue
		}
		; Work out which pixel in the Snapshot was requested
		xpos := xpos - this.Coords.x
		ypos := ypos - this.Coords.y
		
		return this.SnapshotGetColor(xpos,ypos)
	}

	; Gets colour of a pixel relative to the SnapShot
	; Advise use of PixelSnap[] Array instead of this function, as results are cached.
	SnapshotGetColor(xpos, ypos){
		if (!this._SnapshotTaken){
			this.TakeSnapshot()
		}
		if (!this.IsSnapCoord(xpos, ypos)){
			return this._NegativeValue
		}
		ret := GDIP_GetPixel(this.pBitmap, xpos, ypos)
		ret := this.ARGBtoRGB(ret)
		return new this.Color(ret)
	}
	
	; ===== Helper functions, not used internally ============================================================================
	
	; Converts hex ("0xFFFFFF" as a string) to an object of r/g/b integers
	ToRGB(color) {
	    return { "r": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "b": color & 0xFF }
	}

	; ===== Mainly for internal use. ==========================================================================================

	_ResetSnapshot(){
		if (this.pBitmap){
			; delete old bitmap
			Gdip_DisposeImage(this.pBitmap)
		}
		this._SnapshotTaken := 0
		this._PixelCache := [[],[]]
	}
	
	; Converts RGB with Alpha Channel to RGB
	ARGBtoRGB( ARGB ){
		SetFormat, IntegerFast, hex
		ARGB := ARGB & 0x00ffffff
		ARGB .= ""  ; Necessary due to the "fast" mode.
		SetFormat, IntegerFast, d
		return ARGB
	}

	; Constructor
	__New(x,y,w,h){
		this.Coords := {x: x, y: y, w: w, h: h}
		this.pToken := Gdip_Startup()
	}

	; Destructor
	__Delete(){
		Gdip_DisposeImage(this.pBitmap)
		DeleteObject(this.hBitmap)
		Gdip_ShutDown(this.pToken)
	}
	
	; Implement Dynamic Property for Pixel Cache
	__Get(aName, x, y){
		if (aName = "PixelSnap"){
			if (this._PixelCache[x,y] == ""){
				this._PixelCache[x,y] := this.SnapshotGetColor(x,y)
			}
			return this._PixelCache[x,y]
		}
		if (aName = "PixelScreen"){
			col := this.PixelGetColor(x,y)
			; Convert to snapshot coords for array index
			coords := this.ScreenToSnap(x,y)
			x := coords.x
			y := coords.y
			; Check coords are within snapshot
			if (col.rgb != -1){
				this._PixelCache[x,y] := col
			}
			return col
		}
	}
	
	; Colour class - provides r/g/b values via Dynamic Properties
	Class Color {
		__New(RGB){
			this._RGB := RGB
		}
		
		; Implement RGB and R, G, B as Dynamic Properties
		__Get(aName := ""){
			if (aName = "RGB"){
				; Return RGB in Hexadecimal (eg 0xFF00AA) format
				SetFormat, IntegerFast, hex
				ret := this._RGB
				ret += 0
				ret .= ""
				SetFormat, IntegerFast, d
				return ret
			} else if (aName = "R"){
				; Return red in Decimal format
				return (this._RGB >> 16) & 255
			} else if (aName = "G"){
				return (this._RGB >> 8) & 255
			} else if (aName = "B"){
				return this._RGB & 255
			}
		}
	}

}