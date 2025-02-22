Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' الحصول على مسار سطح المكتب
strDesktop = WshShell.SpecialFolders("Desktop")

' إنشاء الاختصار
Set oShortcut = WshShell.CreateShortcut(strDesktop & "\Trading Bot.lnk")
oShortcut.TargetPath = "http://localhost:5000"
oShortcut.IconLocation = "%SystemRoot%\System32\SHELL32.dll,70"
oShortcut.Description = "Trading Bot Application"
oShortcut.Save

' إظهار رسالة تأكيد
MsgBox "تم إنشاء اختصار التطبيق على سطح المكتب بنجاح!", 64, "Trading Bot"

' تنظيف
Set oShortcut = Nothing
Set WshShell = Nothing
Set fso = Nothing
