' XAMPP Background Starter for Registry
' Starts Apache and MySQL in background
Option Explicit

Dim shell
Set shell = CreateObject("WScript.Shell")

' Change to XAMPP directory and start Apache in background
shell.Run "cmd /c cd /d E:\xampp\apache\bin && start /B httpd.exe", 0, False
WScript.Sleep 2000

' Start MySQL in background
shell.Run "cmd /c cd /d E:\xampp\mysql\bin && start /B mysqld.exe --defaults-file=my.ini", 0, False
WScript.Sleep 3000

Set shell = Nothing
WScript.Quit 0
