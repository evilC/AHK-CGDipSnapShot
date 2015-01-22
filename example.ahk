#SingleInstance, force
#include <CGdipSnapshot>

OnExit, GuiClose	; Quit the script when we close the GUI

; Set variables for coordinates
SNAPSHOT_WIDTH := 200
SNAPSHOT_HEIGHT := 200
SNAPSHOT_X := 300
SNAPSHOT_Y := 300

;Create A Gui
w := SNAPSHOT_WIDTH
h := SNAPSHOT_HEIGHT
; GUI item to hold Snapshot Preview. Store HWND in SnapshotPreview so we can send image to it later
Gui, Add, Text, 0xE x5 y5 w%w% h%h% hwndSnapshotPreview
w := w + 10
h := h + 10
Gui, Show, W%w% H%h%

; Create a new Snapshot object and tell it the coordinates we will be snapshotting
snap := new CGdipSnapshot(SNAPSHOT_X,SNAPSHOT_Y,SNAPSHOT_WIDTH,SNAPSHOT_HEIGHT)

; Take a SnapShot
snap.TakeSnapshot()

; Show the Snapshot in the Preview box
snap.ShowSnapshot(SnapshotPreview)

; Demonstrate usage, build output
out := "Snapshot top left: " SNAPSHOT_X "," SNAPSHOT_Y "`n"
out .= "Width: " SNAPSHOT_WIDTH ", Height: " SNAPSHOT_HEIGHT "`n"

; Get a pixel relative to the screen. Will fail as 1,1 is not inside the Snapshot area.
out .= "PixelGetColor(1,1) result: " snap.PixelGetColor(1,1).rgb "`n"

; Get a pixel relative to the screen. Will succeed as is inside the Snapshot area.
out .= "PixelGetColor(" SNAPSHOT_X ", " SNAPSHOT_Y ") result: " snap.PixelGetColor(SNAPSHOT_X,SNAPSHOT_Y).rgb "`n"

; Get a pixel relative to the Snapshot. Note that coordinate 0,0 gives the same value as the Screen coordinate.
; Also note how the pixel value is acessed through the Pixel[] array.
; When doing so, PixelGetColor is automatically called as needed (ie only once for each pixel) and results are Cached (Until a new snapshot is taken)
; This saves having to make loads of variables in your code - just inspect the Pixel[] array as much as you like without worry of wasting DLL calls.
out .= "Pixel[0,0] result: " snap.Pixel[0,0].rgb "`n"

out .= "RGB Values: (" snap.Pixel[0,0].rgb ") = {r: " snap.Pixel[0,0].r ", g: " snap.Pixel[0,0].g ", b: " snap.Pixel[0,0].b "}"

msgbox % out

return

; Quit the script when we close the GUI.
; AHK Automatically runs the GuiClose label when you close the GUI.
GuiClose:
	ExitApp
