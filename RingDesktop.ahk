#Persistent
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
CoordMode, Mouse, Screen

; ################# User settings - adjust these to match your monitor configuration ##############
; NOTE: y = 0 refers to the top of the primary monitor, y increases downwards

edge_spacing := 3
shifts_cm := [7, 0, 0]				; distances from y = 0 in cm
shifts_px := [2052, 0, 2052]			; distances from y = 0 in pixels (see NVidia control panel)
heights_cm := [33.5, 39.4, 50.0]		; monitor height in cm
heights_px := [1080, 2160, 1080]		; monitor height in pixels



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

BetterMouseMove(x, y) {
	; MouseMove does not work properly across screens .. often it is not moved fully to the target position
	; Waiting in a loop until the target position is reached also fails and causes random jumps
	; Hack: repeating many calls works, but is very slow with MouseMove. DllCall instead is fast.
	;
	; Additional calls were added and tested until the target position is always reached and no unexpected jumps occur
	
	DllCall("SetCursorPos", "int", x, "int", y)
	DllCall("SetCursorPos", "int", x, "int", y)
	DllCall("SetCursorPos", "int", x, "int", y)
	DllCall("SetCursorPos", "int", x, "int", y)
	DllCall("SetCursorPos", "int", x, "int", y)
	DllCall("SetCursorPos", "int", x, "int", y)
	DllCall("SetCursorPos", "int", x, "int", y)
}


; ###### print lefts / rights ######
if (false) {
	lefts_str := ""
	rights_str := ""
	Loop, % lefts.MaxIndex() {
		lefts_str .= "" . lefts[A_Index] . " "
		rights_str .= "" . rights[A_Index] . " "
	}
	nexts_str := ""
	Loop, % nexts.MaxIndex() {
		nexts_str .= "" . nexts[A_Index] . " "
	}
	MsgBox, % lefts_str "`n" rights_str "`n" nexts_str
}

; ################# Monitor & adjust mouse position ###############################################

transition_timer:
MouseGetPos, mx, my

for curr, next in nexts {

	; ##### left -> right #####
	r := rights[curr] - edge_spacing	
	if (prev_mx < r && r <= mx) {
		mx := lefts[next] + edge_spacing
		my := (shifts_cm[curr] - shifts_cm[next] + scales[curr] * (prev_my - shifts_px[curr])) / scales[next] + shifts_px[next]

		min_y := shifts_px[next]
		max_y := shifts_px[next] + heights_px[next]
		if (my < min_y) {
			my := min_y
		} else if (my > max_y) {
			my := max_y
		}
	
		BetterMouseMove(mx, my)
	} 

	; ##### left <- right #####
	l := lefts[next] + edge_spacing
	if (prev_mx >= l && l > mx) {
		mx := rights[curr] - edge_spacing
		my := (shifts_cm[next] - shifts_cm[curr] + scales[next] * (prev_my - shifts_px[next])) / scales[curr] + shifts_px[curr]

		min_y := shifts_px[curr]
		max_y := shifts_px[curr] + heights_px[curr]
		if (my < min_y) {
			my := min_y
		} else if (my > max_y) {
			my := max_y
		}
		
		BetterMouseMove(mx, my)
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