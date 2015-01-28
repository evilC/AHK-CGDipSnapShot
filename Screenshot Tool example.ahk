#SingleInstance force
#include <CGdipSnapshot>
coords_set := 0
base_filename := "D:\temp\test\screenshot.png"
gui_open := 0

return


F12::
	if (gui_open){
		soundbeep, 250, 250
		return		
	}
	if (coords_set = 0){
		soundbeep, 500, 250
		mousegetpos, x_pos, y_pos
		coords_set = 1
		return
	} else if (coords_set = 1){
		coords_set = 0
		mousegetpos, x_max, y_max
		if (x_max < x_pos || y_max < y_pos){
			soundbeep, 250, 250
			return
		}
		soundbeep, 1000, 250
		w := x_max - x_pos
		h := y_max - y_pos		
	}
	snap := new CGdipSnapshot(x_pos,y_pos,w,h)
	snap.TakeSnapshot()
	Gui, New
	Gui, Add, Text, 0xE x5 y5 w%w% h%h% hwndSnapshotPreview
	if (w < 200){
		w := 200
	}
	Gui, Add, Text ,, Filename: 
	Gui, Add, Edit, vFileName w%w%, % base_filename
	Gui, Add, Button, gOkPressed Section, Save and copy file path to Clipboard
	Gui, Add, Button, ys gCancelPressed, Cancel
	Gui, Show
	gui_open := 1
	snap.ShowSnapshot(SnapshotPreview)
	return

OKPressed:
	Gui, Submit, Nohide
	snap.SaveSnapshot(Filename)
	snap := ""
	clipboard := Filename
	Gui, Destroy
	return
	
CancelPressed:
	Gui, Destroy
	return