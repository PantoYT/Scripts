' ==== usb_sync_launcher.vbs ====
Option Explicit

Dim shell, batFilePath

' Path to your batch file
batFilePath = "C:\Scripts\usb_sync.bat"

' Create shell object
Set shell = CreateObject("WScript.Shell")

' Run batch silently, non-blocking
shell.Run Chr(34) & batFilePath & Chr(34), 0, False

' Clean up
Set shell = Nothing
