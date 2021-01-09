{
#Persistent
#SingleInstance Force

SM_CMONITORS := 80 ; numeric value to get number of desktop monitors
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

}
return


detect_edge:
{

MouseGetPos, x, y

if (x > x_max - edge_pixels)
	MouseMove, x_min + edge_pixels, y, 0

if(x < x_min + edge_pixels)
	MouseMove, x_max - edge_pixels, y, 0

return
}


~^!r::
Menu, Tray, Icon
Reload
return

~^!y::
Menu, Tray, NoIcon
return