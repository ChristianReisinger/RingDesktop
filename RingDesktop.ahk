#Persistent
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
CoordMode, Mouse, Screen

; ################# User settings - adjust these to match your monitor configuration ##############
; NOTE: y = 0 is the top of the primary monitor

edge_spacing := 3
shifts_cm := [5.7, 0, 5.7]				; distances from y = 0 in cm
shifts_px := [2130, 0, 2130]				; distances from y = 0 in pixels
heights_cm := [33.5, 39.4, 33.5]			; monitor height in cm
heights_px := [1080, 2160, 1080]			; monitor height in pixels



; ################# Initialize script #############################################################

scales := []
Loop, % heights_cm.MaxIndex() {
	scales.Push(heights_cm[A_Index] / heights_px[A_Index])
}

SysGet, monitor_num, MonitorCount
nexts := []
lefts := []
rights := []
Loop, %monitor_num% {
	nexts.Push(Mod(A_Index, monitor_num) + 1)
	SysGet, bounds, Monitor, %A_Index%
	lefts.Push(boundsLeft)
	rights.Push(boundsRight)
}
bubble_sort(lefts)
bubble_sort(rights)

MouseGetPos, prev_mx, prev_my
SetTimer, transition_timer, 10

bubble_sort(arr) {
	Loop, % arr.MaxIndex() - 1 {
		Loop, % arr.MaxIndex() - A_Index {
			j := A_Index
			if (arr[j] > arr[j+1]) {
				left := arr[j]
				arr[j] := arr[j+1]
				arr[j+1] := left
			}
		}
	}
}


; ###### print lefts / rights ######
if(false) {
lefts_str := ""
rights_str := ""
Loop, % lefts.MaxIndex() {
	lefts_str .= "" . lefts[A_Index] . " "
	rights_str .= "" . rights[A_Index] . " "
}
MsgBox, % lefts_str "`n" rights_str
}

; ################# Monitor & adjust mouse position ###############################################

transition_timer:
MouseGetPos, mx, my

for curr, next in nexts {

	; ##### left -> right #####
	if (prev_mx < rights[curr] - edge_spacing && mx >= rights[curr] - edge_spacing) {
		mx := lefts[next] + edge_spacing
		my := (shifts_cm[curr] - shifts_cm[next] + scales[curr] * (prev_my - shifts_px[curr])) / scales[next] + shifts_px[next]

		min_y := shifts_px[next]
		max_y := shifts_px[next] + heights_px[next]
		if (my < min_y) {
			my := min_y
		} else if (my > max_y) {
			my := max_y
		}
		
		MouseMove, mx, my, 0
		BlockInput, Mouse
	}

	; ##### left <- right #####
	if (prev_mx >= lefts[next] + edge_spacing && mx < lefts[next] + edge_spacing) {
		mx := rights[curr] - edge_spacing
		my := (shifts_cm[next] - shifts_cm[curr] + scales[next] * (prev_my - shifts_px[next])) / scales[curr] + shifts_px[curr]

		min_y := shifts_px[curr]
		max_y := shifts_px[curr] + heights_px[curr]
		if (my < min_y) {
			my := min_y
		} else if (my > max_y) {
			my := max_y
		}

		MouseMove, mx, my, 0
		BlockInput, Mouse
	}
}

prev_mx := mx
prev_my := my

return


; #################################################################################################

~^!r::
Menu, Tray, Icon
Reload
return

~^!y::
Menu, Tray, NoIcon
return