#SingleInstance Force
; SpotifyGlobalKeys.ahk:
; AutoHotkey script to control Spotify with global keyboard shortcuts
; Author: James Teh <jamie@jantrid.net>
; Copyright 2017-2018 James Teh
; License: GNU General Public License version 2.0

DetectHiddenWindows, On

; Get the HWND of the Spotify main window.
getSpotifyHwnd() {
	WinGet, spotifyHwnd, ID, ahk_exe spotify.exe
	Return spotifyHwnd
}

; Send a key to Spotify.
spotifyKey(key) {
	spotifyHwnd := getSpotifyHwnd()
	; Chromium ignores keys when it isn't focused.
	; Focus the document window without bringing the app to the foreground.
	ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%
	ControlSend, , %key%, ahk_id %spotifyHwnd%
	Return
}

; ctrl+shift+y: Play/Pause
^+y::
{
	spotifyKey("{Space}")
	Return
}

; ctrl+shift+u: Next
^+u::
{
	spotifyKey("^{Right}")
	Return
}

; ctrl+shift+i: Previous
^+i::
{
	spotifyKey("^{Left}")
	Return
}

; shift+y: Volume up
+y::
{
	spotifyKey("^{Up}")
	Return
}

; shift+u: Volume down
+u::
{
	spotifyKey("^{Down}")
	Return
}

; shift+i: Show Spotify
+i::
{
	spotifyHwnd := getSpotifyHwnd()
	WinGet, style, Style, ahk_id %spotifyHwnd%
	if (style & 0x10000000) { ; WS_VISIBLE
		WinHide, ahk_id %spotifyHwnd%
	} Else {
		WinShow, ahk_id %spotifyHwnd%
		WinActivate, ahk_id %spotifyHwnd%
	}
	Return 
}