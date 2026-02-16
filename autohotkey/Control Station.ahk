#SingleInstance Force
DetectHiddenWindows, On

; Get the HWND of the Spotify and Discord main windows.
getSpotifyHwnd() {
	WinGet, spotifyHwnd, ID, ahk_exe spotify.exe
	Return spotifyHwnd
}
getDiscordHwnd() {
	WinGet, discordHwnd, ID, ahk_exe discord.exe
	Return discordHwnd
}

; Send a key to Spotify and Discord.
spotifyKey(key) {
	spotifyHwnd := getSpotifyHwnd()
	; Chromium ignores keys when it isn't focused.
	; Focus the document window without bringing the app to the foreground.
	ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%
	ControlSend, , %key%, ahk_id %spotifyHwnd%
	Return
}
discordKey(key) {
	discordHwnd := getDiscordHwnd()
	; Chromium ignores keys when it isn't focused.
	; Focus the document window without bringing the app to the foreground.
	ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %discordHwnd%
	ControlSend, , %key%, ahk_id %discordHwnd%
	Return
}

; ctrl+shift+y: Play/Pause Spotify
^+y::
{
	spotifyKey("{Space}")
	Return
}

; ctrl+shift+u: Next Spotify
^+u::
{
	spotifyKey("^{Right}")
	Return
}

; ctrl+shift+i: Previous Spotify
^+i::
{
	spotifyKey("^{Left}")
	Return
}

; alt+y: Volume up Spotify
!y::
{
	spotifyKey("^{Up}")
	Return
}

; alt+u: Volume down Spotify
!u::
{
	spotifyKey("^{Down}")
	Return
}

; alt+i: Show Spotify 
!i::
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

; ctrl+alt+i: Show Discord 
^!i::
{
	discordHwnd := getDiscordHwnd()
	WinGet, style, Style, ahk_id %discordHwnd%
	if (style & 0x10000000) { ; WS_VISIBLE
		WinHide, ahk_id %discordHwnd%
	} Else {
		WinShow, ahk_id %discordHwnd%
		WinActivate, ahk_id %discordHwnd%
	}
	Return 
}

; Workspace_Main
^+#z::
{
    Run, "C:\Users\halas\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Workspace_Main.lnk"
    Return
}

