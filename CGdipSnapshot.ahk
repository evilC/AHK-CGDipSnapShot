/*
CGDipSnapShot.ahk
By evilc@evilc.com

Use Gdip_All.ahk from this page: http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
Place it in C:\Program Files\Autohotkey\Lib (Create Lib folder if it does not exist)

ToDo:
* Set Pos / Size command (clear cache too)
* Compare to compare to this (only accept one other colour as arg)
* "Private" stuff to underscore prefix

*/
#include <gdip_all>

Class CGDipSnapShot {
	pToken := 0
	pBitmap := 0 							; bitmap image
	hBitmap := 0 							; HWND for bitmap?
	Coords := {x: 0, y: 0, w: 0, h: 0} 		; Coords of snapshot area relative to screen
	_NegativeValue := {rgb: -1, r: -1, g: -1, b: -1}
	_PixelCache := [[],[]]

	; === User Functions ==================================================================================================================================
	; Intended for use by people using the class.

	; Take a new Snapshot
	TakeSnapshot(){
		if (this.pBitmap){
			; delete old bitmap
			Gdip_DisposeImage(this.pBitmap)
		}
		this.pBitmap := GDIP_BitmapFromScreen(this.Coords.x "|" this.Coords.y "|" this.Coords.w "|" this.Coords.h)
		this._ResetPixelCache()
		return
	}

	; Show the Snapshot in the specified HWND.
	; Declare a regular AHK GUI Textbox like so:
	; Gui, Add, Text, 0xE x5 y5 w200 h200 hwndSnapshotPreview
	; Then ShowSnapshot(SnapshotPreview) to show the snapshot in that GUI item
	ShowSnapshot(hwnd){
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
		return Gdip_SaveBitmapToFile(this.pBitmap, filename, quality)
	}

	; Gets colour of a pixel relative to the screen (As long as it is inside the snapshot)
	; Returns -1 if asked for a pixel outside the snapshot
	PixelGetColor(xpos,ypos){
		; Return RGB value of -1 if outside snapshot area
		if (xpos < this.Coords.x || ypos < this.Coords.y || xpos > (this.Coords.x + this.Coords.w) || ypos > (this.Coords.y + this.Coords.h) ){
			return this._NegativeValue
		}
		; Work out which pixel in the Snapshot was requested
		xpos := xpos - this.Coords.x
		ypos := ypos - this.Coords.y
		
		return this.SnapshotGetColor(xpos,ypos)
	}

	; Gets colour of a pixel relative to the SnapShot
	SnapshotGetColor(xpos, ypos){
		if (xpos > this.Coords.w || ypos > this.Coords.h){
			return -1
		}
		ret := GDIP_GetPixel(this.pBitmap, xpos, ypos)
		ret := this.ARGBtoRGB(ret)
		return new this.Color(ret)
	}

	; Converts hex ("0xFFFFFF" as a string) to an object of r/g/b integers
	ToRGB(color) {
	    return { "r": (color >> 16) & 0xFF, "g": (color >> 8) & 0xFF, "b": color & 0xFF }
	}

	; Compares r/g/b integer objects, with a tolerance
	; returns true or false
	Compare(c1, c2, tol := 20) {
		diff := Abs( c1.r - c2.r ) "," Abs( c1.g - c2.g ) "," Abs( c1.b - c2.b )
		sort diff,N D,

		StringSplit, diff, diff, `,
		return diff%diff0% < tol
	}

	; Returns the Difference between two colors
	Diff(c1,c2){
		diff := Abs( c1.r - c2.r ) "," Abs( c1.g - c2.g ) "," Abs( c1.b - c2.b )
		sort diff,N D,

		StringSplit, diff, diff, `,
		return diff%diff0% < tol
	}

	; ===== Mainly for internal use. ==========================================================================================

	_ResetPixelCache(){
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
		if (aName = "Pixel"){
			if (this._PixelCache[x,y] == ""){
				this._PixelCache[x,y] := this.SnapshotGetColor(x,y)
			}
			return this._PixelCache[x,y]
		}
	}
	
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