Set objShell = CreateObject("Shell.Application")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Get the directory where this VBS script is located
strScriptPath = objFSO.GetParentFolderName(WScript.ScriptFullName)
strPythonScript = objFSO.BuildPath(strScriptPath, "contextmenu_manager.py")

' Check if Python script exists
If Not objFSO.FileExists(strPythonScript) Then
    MsgBox "Error: contextmenu_manager.py not found in the same directory!", vbCritical, "File Not Found"
    WScript.Quit 1
End If

' Run Python script as administrator
objShell.ShellExecute "python", """" & strPythonScript & """", "", "runas", 1
