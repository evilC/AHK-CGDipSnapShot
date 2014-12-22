#SingleInstance, force
#include CGdipSnapshot.ahk

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
out .= "PixelGetColor(1,1) result: " snap.PixelGetColor(1,1) "`n"

; Get a pixel relative to the screen. Will succeed as is not inside the Snapshot area.
out .= "PixelGetColor(" SNAPSHOT_X ", " SNAPSHOT_Y ") result: " snap.PixelGetColor(SNAPSHOT_X,SNAPSHOT_Y) "`n"

; Get a pixel relative to the Snapshot. Note that coordinate 0,0 gives the same value as the Screen coordinate
out .= "SnapshotGetColor(0,0) result: " snap.SnapshotGetColor(0,0) "`n"

col := snap.SnapshotGetColor(1,1)
out .= "ToRGB(" col ") = "
col := snap.ToRGB(col)
out .= "{r: " col.r ", g: " col.g ", b: " col.b "}"

msgbox % out

return

; Quit the script when we close the GUI.
; AHK Automatically runs the GuiClose label when you close the GUI.
GuiClose:
	ExitApp
