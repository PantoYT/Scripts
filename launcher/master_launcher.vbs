' ===================================================
' Script Launcher Master
' ===================================================
Option Explicit

Dim fso, scriptDir, coreLibPath
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
coreLibPath = scriptDir & "\launcher_core.vbs"

If fso.FileExists(coreLibPath) Then
    ExecuteGlobal fso.OpenTextFile(coreLibPath).ReadAll()
Else
    MsgBox "ERROR: Cannot find launcher_core.vbs", vbCritical, "Error"
    WScript.Quit 1
End If

Dim configPath, logPath, mode
configPath = scriptDir & "\config.ini"
logPath = scriptDir & "\launcher.log"

If WScript.Arguments.Count > 0 Then
    mode = LCase(WScript.Arguments(0))
Else
    mode = "gui"
End If

Select Case mode
    Case "/start", "-start", "start"
        StartAllMode()
    Case "/stop", "-stop", "stop"
        StopAllMode()
    Case "/restart", "-restart", "restart"
        RestartMode()
    Case Else
        GuiMode()
End Select

WScript.Quit 0

' ===================================================
' Start all AutoStart scripts
' ===================================================
Sub StartAllMode()
    Dim sections, section, config
    Dim autoStart, scriptType, scriptPath, processName, processSearch
    Dim launched, restarted
    
    WriteLog logPath, "=== START ALL MODE ==="
    
    launched = 0
    restarted = 0
    
    Set sections = GetIniSections(configPath)
    
    For Each section In sections.Keys
        Set config = ReadIniSection(configPath, section)
        
        If config.Exists("AutoStart") Then
            autoStart = LCase(config("AutoStart"))
            
            If autoStart = "true" Then
                scriptType = config("Type")
                scriptPath = config("Path")
                processName = config("ProcessName")
                
                If config.Exists("ProcessSearch") Then
                    processSearch = config("ProcessSearch")
                Else
                    processSearch = ""
                End If
                
                If IsProcessRunning(processName, processSearch) Then
                    WriteLog logPath, section & " - Already running, restarting..."
                    KillProcess processName, processSearch
                    WScript.Sleep 1000
                    restarted = restarted + 1
                End If
                
                If LaunchScript(scriptType, scriptPath) Then
                    WriteLog logPath, section & " - Started successfully"
                    launched = launched + 1
                Else
                    WriteLog logPath, section & " - FAILED to start"
                End If
                
                WScript.Sleep 500
            End If
        End If
    Next
    
    WriteLog logPath, "Complete: " & launched & " launched, " & restarted & " restarted"
End Sub

' ===================================================
' Stop all scripts
' ===================================================
Sub StopAllMode()
    Dim sections, section, config
    Dim processName, processSearch, killed, totalKilled
    
    WriteLog logPath, "=== STOP ALL MODE ==="
    
    totalKilled = 0
    
    Set sections = GetIniSections(configPath)
    
    For Each section In sections.Keys
        Set config = ReadIniSection(configPath, section)
        
        If config.Exists("ProcessName") Then
            processName = config("ProcessName")
            
            If config.Exists("ProcessSearch") Then
                processSearch = config("ProcessSearch")
            Else
                processSearch = ""
            End If
            
            killed = KillProcess(processName, processSearch)
            
            If killed > 0 Then
                WriteLog logPath, section & " - Stopped (" & killed & " process(es))"
                totalKilled = totalKilled + killed
            End If
        End If
    Next
    
    If totalKilled > 0 Then
        WriteLog logPath, "Stop complete: " & totalKilled & " process(es) terminated"
        MsgBox "Stopped " & totalKilled & " script(s)", vbInformation, "Done"
    Else
        WriteLog logPath, "No scripts were running"
        MsgBox "No scripts were running", vbInformation, "Done"
    End If
End Sub

' ===================================================
' Restart all
' ===================================================
Sub RestartMode()
    WriteLog logPath, "=== RESTART MODE ==="
    StopAllMode()
    WScript.Sleep 2000
    StartAllMode()
End Sub

' ===================================================
' GUI Mode
' ===================================================
Sub GuiMode()
    Dim choice, menu, sections, section, config
    Dim running, status, menuItems, counter
    
    Set sections = GetIniSections(configPath)
    Set menuItems = CreateObject("Scripting.Dictionary")
    
    menu = "====================================================" & vbCrLf
    menu = menu & "       SCRIPT LAUNCHER" & vbCrLf
    menu = menu & "====================================================" & vbCrLf & vbCrLf
    
    counter = 1
    
    For Each section In sections.Keys
        Set config = ReadIniSection(configPath, section)
        
        If config.Exists("ProcessName") Then
            If config.Exists("ProcessSearch") Then
                running = IsProcessRunning(config("ProcessName"), config("ProcessSearch"))
            Else
                running = IsProcessRunning(config("ProcessName"), "")
            End If
            
            If running Then
                status = "[RUNNING]"
            Else
                status = "[STOPPED]"
            End If
            
            menu = menu & counter & ". " & status & " " & section & vbCrLf
            
            menuItems.Add CStr(counter), section
            counter = counter + 1
        End If
    Next
    
    menu = menu & vbCrLf
    menu = menu & "----------------------------------------------------" & vbCrLf
    menu = menu & "A - Start All" & vbCrLf
    menu = menu & "S - Stop All" & vbCrLf
    menu = menu & "R - Restart All" & vbCrLf
    menu = menu & "Q - Quit" & vbCrLf
    menu = menu & "----------------------------------------------------" & vbCrLf & vbCrLf
    menu = menu & "Your choice:"
    
    choice = InputBox(menu, "Script Launcher", "A")
    
    If choice = "" Then
        WScript.Quit 0
    End If
    
    choice = UCase(Trim(choice))
    
    Select Case choice
        Case "A"
            StartAllMode()
            MsgBox "Started all scripts", vbInformation, "Done"
            
        Case "S"
            StopAllMode()
            
        Case "R"
            RestartMode()
            MsgBox "Restarted all scripts", vbInformation, "Done"
            
        Case "Q"
            WScript.Quit 0
            
        Case Else
            If menuItems.Exists(choice) Then
                ToggleScript menuItems(choice)
            Else
                MsgBox "Invalid choice", vbExclamation, "Error"
            End If
    End Select
    
    GuiMode()
End Sub

' ===================================================
' Toggle individual script
' ===================================================
Sub ToggleScript(scriptName)
    Dim config, processName, processSearch, scriptType, scriptPath, running
    
    Set config = ReadIniSection(configPath, scriptName)
    
    processName = config("ProcessName")
    
    If config.Exists("ProcessSearch") Then
        processSearch = config("ProcessSearch")
    Else
        processSearch = ""
    End If
    
    running = IsProcessRunning(processName, processSearch)
    
    If running Then
        KillProcess processName, processSearch
        WriteLog logPath, scriptName & " - Stopped by user"
        MsgBox scriptName & " stopped", vbInformation, "Done"
    Else
        scriptType = config("Type")
        scriptPath = config("Path")
        
        If LaunchScript(scriptType, scriptPath) Then
            WriteLog logPath, scriptName & " - Started by user"
            MsgBox scriptName & " started", vbInformation, "Done"
        Else
            WriteLog logPath, scriptName & " - FAILED to start"
            MsgBox "Failed to start " & scriptName, vbCritical, "Error"
        End If
    End If
End Sub
