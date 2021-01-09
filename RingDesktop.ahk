{
#Persistent
#SingleInstance Force

SM_CMONITORS := 80 ; 'number of desktop monitors' attribute id
SysGet, monitor_num, % SM_CMONITORS

x_max := 0
x_min := 0

Loop, % monitor_num {
	SysGet, monitor_bounds, Monitor, %A_index%
	if (monitor_boundsLeft < x_min)
		x_min := monitor_boundsLeft
	if (monitor_boundsRight > x_max)
		x_max := monitor_boundsRight
}

CoordMode, Mouse, Screen

edge_pixels = 2

SetTimer, detect_edge, 100

; ---------------------------------------------

left_mon_height_cm := 50
left_mon_elev_cm := 4.1
right_mon_height_cm := 33.62
h_px := 1080
w_px := 1920
MouseGetPos, pre_switchx

;SetTimer, detect_switch, 10

}
return

detect_edge:
MouseGetPos, x, y

if (x > x_max - edge_pixels) {
	MouseMove, x_min + edge_pixels, y, 0
	ToolTip,  x_min = %x_min%
}

if(x < x_min + edge_pixels) {
	MouseMove, x_max - edge_pixels, y, 0
}

return


detect_switch:
MouseGetPos, curr_switchx, curr_switchy
if(abs(pre_switchx - curr_switchx) < 100) {
	if (pre_switchx >= 0 && curr_switchx < 0) {
		new_switchy := (left_mon_height_cm + left_mon_elev_cm - (1 - curr_switchy / h_px) * right_mon_height_cm) * h_px / left_mon_height_cm
		new_switchy := min(h_px, max(0, floor(new_switchy)))
		if (GetKeyState("LButton") == 0) {
			switch_notok := true
			while (switch_notok) {
				MouseMove, curr_switchx, new_switchy, 0
				MouseGetPos, confirm_switchx, confirm_switchy
				switch_notok := abs(confirm_switchy - new_switchy) > 20
			}
		}
	} else if (pre_switchx < 0 && curr_switchx >= 0) {
		new_switchy := (right_mon_height_cm - left_mon_elev_cm - (1 - curr_switchy / h_px) * left_mon_height_cm) * h_px / right_mon_height_cm
		new_switchy := min(h_px, max(0, floor(new_switchy)))
		if (GetKeyState("LButton") == 0) {
			switch_notok := true
			while (switch_notok) {
				MouseMove, curr_switchx, new_switchy, 0
				MouseGetPos, confirm_switchx, confirm_switchy
				switch_notok := abs(confirm_switchy - new_switchy) > 20
			}
		}
	}
}
pre_switchx := curr_switchx
return

; ---------------------------------------------

~^!r::
Menu, Tray, Icon
Reload
return

~^!y::
Menu, Tray, NoIcon
return