Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' الحصول على مسار سطح المكتب
strDesktop = WshShell.SpecialFolders("Desktop")

' الحصول على المسار الحالي
currentDir = fso.GetParentFolderName(WScript.ScriptFullName)

' إنشاء الاختصار
Set oShortcut = WshShell.CreateShortcut(strDesktop & "\Crypto Trading.lnk")
oShortcut.TargetPath = "wscript.exe"
oShortcut.Arguments = """" & currentDir & "\launch.vbs" & """"
oShortcut.WorkingDirectory = currentDir
oShortcut.WindowStyle = 7  ' تشغيل مخفي
oShortcut.IconLocation = currentDir & "\windows\runner\resources\app_icon.ico"
oShortcut.Description = "Crypto Trading Application"
oShortcut.Save

MsgBox "تم إنشاء الاختصار بنجاح!", 64, "Crypto Trading"

Set oShortcut = Nothing
Set WshShell = Nothing
Set fso = Nothing
