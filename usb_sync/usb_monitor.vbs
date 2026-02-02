' ===================================================
' USB Sync Monitor - VBScript wrapper
' Ensures syncs_usb_v2.bat stays running and auto-restarts on crash
' ===================================================
Option Explicit

Dim fso, shell, logPath, processName
Dim isRunning, lastCheck, restartCount
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

logPath = "E:\Scripts\logs\usb_monitor.log"
processName = "cmd.exe"
restartCount = 0

If Not fso.FolderExists("E:\Scripts\logs") Then
    fso.CreateFolder "E:\Scripts\logs"
End If

LogMessage "USB Monitor started"

Do While True
    WScript.Sleep 5000  ' Check every 5 seconds
    
    If Not IsProcessRunning(processName, "syncs_usb_v2.bat") Then
        LogMessage "USB Sync process not found, restarting..."
        
        If restartCount > 10 Then
            LogMessage "ERROR: Too many restarts, giving up"
            Exit Do
        End If
        
        If Not StartUSBSync() Then
            LogMessage "ERROR: Failed to start USB Sync"
            restartCount = restartCount + 1
        Else
            restartCount = 0
        End If
    End If
Loop

LogMessage "USB Monitor terminated"

' ===================================================
' Check if process is running
' ===================================================
Function IsProcessRunning(processName, searchString)
    Dim objWMI, colProcesses, objProcess
    
    On Error Resume Next
    Set objWMI = GetObject("winmgmts:\\.\root\cimv2")
    
    If Err.Number <> 0 Then
        IsProcessRunning = False
        Exit Function
    End If
    
    Set colProcesses = objWMI.ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" & processName & "'")
    
    If colProcesses.Count = 0 Then
        IsProcessRunning = False
        Exit Function
    End If
    
    If searchString = "" Then
        IsProcessRunning = True
    Else
        For Each objProcess In colProcesses
            If Not IsNull(objProcess.CommandLine) Then
                If InStr(1, objProcess.CommandLine, searchString, vbTextCompare) > 0 Then
                    IsProcessRunning = True
                    Exit Function
                End If
            End If
        Next
        IsProcessRunning = False
    End If
End Function

' ===================================================
' Start USB Sync
' ===================================================
Function StartUSBSync()
    On Error Resume Next
    
    shell.Run "cmd.exe /c start /min E:\Scripts\usb_sync\syncs_usb_v2.bat", 0, False
    
    If Err.Number <> 0 Then
        LogMessage "ERROR starting process: " & Err.Description
        StartUSBSync = False
    Else
        WScript.Sleep 2000  ' Give it time to start
        LogMessage "USB Sync started"
        StartUSBSync = True
    End If
End Function

' ===================================================
' Log message
' ===================================================
Sub LogMessage(msg)
    Dim logFile
    On Error Resume Next
    
    Set logFile = fso.OpenTextFile(logPath, 8, True)  ' 8 = ForAppending
    logFile.WriteLine "[" & Now() & "] " & msg
    logFile.Close
    
    Set logFile = Nothing
End Sub
