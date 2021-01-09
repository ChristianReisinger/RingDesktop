#Persistent
DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr")
CoordMode, Mouse, Screen

; ################# User settings - adjust these to match your monitor configuration ##############

edge_spacing := 3
heights := [0, 0, 0]					; distances from the screen top in cm
scales := [33.5 / 1080, 39.4 / 2160, 33.5 / 1080]	; height in cm / height in pixels



; ################# Initialize script #############################################################


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



; ################# Monitor & adjust mouse position ###############################################

transition_timer:
MouseGetPos, mx, my

for curr, next in nexts {

	; ##### left -> right #####
	if (prev_mx < rights[curr] - edge_spacing && mx >= rights[curr] - edge_spacing) {
		mx := lefts[next] + edge_spacing
		my := (heights[curr] - heights[next] + scales[curr] * prev_my) / scales[next]
		
		MouseMove, mx, my, 0
		BlockInput, Mouse
	}

	; ##### left <- right #####
	if (prev_mx >= lefts[next] + edge_spacing && mx < lefts[next] + edge_spacing) {
		mx := rights[curr] - edge_spacing
		my := (heights[next] - heights[curr] + scales[next] * prev_my) / scales[curr]

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