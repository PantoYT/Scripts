#SingleInstance Force
; "CTRL + Alt + S" for Launching spotify / Activating the window / Minimizing the window
^!S::
IfWinExist ahk_class SpotifyMainWindow
{
	ifWinActive ahk_class SpotifyMainWindow
	{
		WinMinimize
	}
	else
	{
		WinActivate
	}
}
else
{
	run "C:\Users\halas\AppData\Roaming\Spotify\Spotify.exe"
}
return

; "CTRL + Alt + U"  Skip to the Next song.
^!U::
DetectHiddenWindows, On
WinMenuSelectItem, ahk_class SpotifyMainWindow, , 4&, 3&
DetectHiddenWindows, Off
return

; "CTRL + Alt + Y"  Play/Pause the song.
^!Y::
DetectHiddenWindows, On
WinMenuSelectItem, ahk_class SpotifyMainWindow, , 4&, 1&
DetectHiddenWindows, Off
return