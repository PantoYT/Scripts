#SingleInstance Force
; Spadi to Femboy

getDiscordHwnd() {
	WinGet, discordHwnd, ID, ahk_exe discord.exe
	Return discordHwnd
}

discordKey(key) {
	discordHwnd := getDiscordHwnd()
	; Chromium ignores keys when it isn't focused.
	; Focus the document window without bringing the app to the foreground.
	ControlFocus, Chrome_RenderWidgetHostHWND1, ahk_id %spotifyHwnd%
	ControlSend, , %key%, ahk_id %discordHwnd%
	Return
}

; ctrl+alt+y: Mute on Discord
^!y::
{
	discordKey("^+{m}")
	Return

}

; ctrl+alt+u: Deafen on Discord
^!u::
{
	discordKey("^+{d}")
	Return
}

