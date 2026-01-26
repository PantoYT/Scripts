' ==== usb_sync_launcher.vbs ====
Option Explicit

Dim shell, batFilePath

' Path to your batch file
batFilePath = "E:\Scripts\usb_sync\syncs_usb_v2.bat"

' Create shell object
Set shell = CreateObject("WScript.Shell")

' Run batch silently, non-blocking
shell.Run Chr(34) & batFilePath & Chr(34), 0, False

' Clean up
Set shell = Nothing
