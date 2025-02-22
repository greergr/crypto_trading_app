Option Explicit

Dim WshShell, fso, appPath, currentDir

Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' الحصول على المسار الحالي
currentDir = fso.GetParentFolderName(WScript.ScriptFullName)

' تغيير المجلد الحالي
WshShell.CurrentDirectory = currentDir

' تشغيل التطبيق بدون نافذة
CreateObject("WScript.Shell").Run "cmd /c flutter run -d windows", 0

Set WshShell = Nothing
Set fso = Nothing
