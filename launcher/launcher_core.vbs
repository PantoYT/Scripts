' ===================================================
' Launcher Core Library
' Common functions for process management
' ===================================================
Option Explicit

' ---------------------------------------------------
' Check if a process is running
' ---------------------------------------------------
Function IsProcessRunning(processName, searchString)
    Dim objWMI, colProcesses, objProcess
    Dim found
    
    found = False
    
    On Error Resume Next
    Set objWMI = GetObject("winmgmts:\\.\root\cimv2")
    
    If Err.Number <> 0 Then
        IsProcessRunning = False
        Exit Function
    End If
    
    Set colProcesses = objWMI.ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" & processName & "'")
    
    For Each objProcess In colProcesses
        If searchString = "" Or IsNull(searchString) Then
            found = True
            Exit For
        End If
        
        If Not IsNull(objProcess.CommandLine) Then
            If InStr(1, objProcess.CommandLine, searchString, vbTextCompare) > 0 Then
                found = True
                Exit For
            End If
        End If
    Next
    
    Set colProcesses = Nothing
    Set objWMI = Nothing
    
    IsProcessRunning = found
End Function

' ---------------------------------------------------
' Kill a process
' ---------------------------------------------------
Function KillProcess(processName, searchString)
    Dim objWMI, colProcesses, objProcess
    Dim killed
    
    killed = 0
    
    On Error Resume Next
    Set objWMI = GetObject("winmgmts:\\.\root\cimv2")
    
    If Err.Number <> 0 Then
        KillProcess = 0
        Exit Function
    End If
    
    Set colProcesses = objWMI.ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" & processName & "'")
    
    For Each objProcess In colProcesses
        If searchString = "" Or IsNull(searchString) Then
            objProcess.Terminate()
            killed = killed + 1
        Else
            If Not IsNull(objProcess.CommandLine) Then
                If InStr(1, objProcess.CommandLine, searchString, vbTextCompare) > 0 Then
                    objProcess.Terminate()
                    killed = killed + 1
                End If
            End If
        End If
    Next
    
    If killed > 0 Then
        WScript.Sleep 500
    End If
    
    Set colProcesses = Nothing
    Set objWMI = Nothing
    
    KillProcess = killed
End Function

' ---------------------------------------------------
' Launch a script
' ---------------------------------------------------
Function LaunchScript(scriptType, scriptPath)
    Dim shell, fso
    Dim result
    
    result = False
    
    On Error Resume Next
    Set shell = CreateObject("WScript.Shell")
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    If Not fso.FileExists(scriptPath) Then
        LaunchScript = False
        Exit Function
    End If
    
    Select Case LCase(scriptType)
        Case "vbs"
            shell.Run "wscript.exe """ & scriptPath & """", 0, False
            result = True
            
        Case "bat"
            shell.Run "cmd.exe /c """ & scriptPath & """", 0, False
            result = True
            
        Case "python"
            shell.Run "python """ & scriptPath & """", 0, False
            result = True
            
        Case "exe"
            shell.Run """" & scriptPath & """", 1, False
            result = True
            
        Case "ahk"
            shell.Run """" & scriptPath & """", 1, False
            result = True
            
        Case Else
            result = False
    End Select
    
    Set fso = Nothing
    Set shell = Nothing
    
    LaunchScript = result
End Function

' ---------------------------------------------------
' Read INI section
' ---------------------------------------------------
Function ReadIniSection(iniPath, sectionName)
    Dim fso, file, line, inSection, dict
    Dim key, value, pos
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set dict = CreateObject("Scripting.Dictionary")
    
    If Not fso.FileExists(iniPath) Then
        Set ReadIniSection = dict
        Exit Function
    End If
    
    Set file = fso.OpenTextFile(iniPath, 1)
    inSection = False
    
    Do Until file.AtEndOfStream
        line = Trim(file.ReadLine)
        
        If Len(line) > 0 And Left(line, 1) <> ";" Then
            If Left(line, 1) = "[" And Right(line, 1) = "]" Then
                If inSection Then
                    Exit Do
                End If
                
                If Mid(line, 2, Len(line) - 2) = sectionName Then
                    inSection = True
                End If
            ElseIf inSection Then
                pos = InStr(line, "=")
                If pos > 0 Then
                    key = Trim(Left(line, pos - 1))
                    value = Trim(Mid(line, pos + 1))
                    dict.Add key, value
                End If
            End If
        End If
    Loop
    
    file.Close
    Set file = Nothing
    Set fso = Nothing
    
    Set ReadIniSection = dict
End Function

' ---------------------------------------------------
' Get all sections
' ---------------------------------------------------
Function GetIniSections(iniPath)
    Dim fso, file, line, sections
    Dim sectionName
    
    Set fso = CreateObject("Scripting.FileSystemObject")
    Set sections = CreateObject("Scripting.Dictionary")
    
    If Not fso.FileExists(iniPath) Then
        Set GetIniSections = sections
        Exit Function
    End If
    
    Set file = fso.OpenTextFile(iniPath, 1)
    
    Do Until file.AtEndOfStream
        line = Trim(file.ReadLine)
        
        If Len(line) > 0 And Left(line, 1) = "[" And Right(line, 1) = "]" Then
            sectionName = Mid(line, 2, Len(line) - 2)
            If Not sections.Exists(sectionName) Then
                sections.Add sectionName, sectionName
            End If
        End If
    Loop
    
    file.Close
    Set file = Nothing
    Set fso = Nothing
    
    Set GetIniSections = sections
End Function

' ---------------------------------------------------
' Write to log
' ---------------------------------------------------
Sub WriteLog(logPath, message)
    Dim fso, file, timestamp
    
    On Error Resume Next
    Set fso = CreateObject("Scripting.FileSystemObject")
    
    timestamp = Now()
    
    Set file = fso.OpenTextFile(logPath, 8, True)
    file.WriteLine "[" & timestamp & "] " & message
    file.Close
    
    Set file = Nothing
    Set fso = Nothing
End Sub
