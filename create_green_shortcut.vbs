Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' الحصول على مسار سطح المكتب
strDesktop = WshShell.SpecialFolders("Desktop")

' إنشاء الاختصار
Set oShortcut = WshShell.CreateShortcut(strDesktop & "\Crypto Trading.lnk")
oShortcut.TargetPath = "wscript.exe"
oShortcut.Arguments = """" & "c:\Users\PC\Desktop\crypto_trading_app\run_app.vbs" & """"
oShortcut.WorkingDirectory = "c:\Users\PC\Desktop\crypto_trading_app"
oShortcut.IconLocation = "%SystemRoot%\System32\shell32.dll,23"  ' أيقونة خضراء
oShortcut.Description = "Crypto Trading Application"
oShortcut.Save

MsgBox "تم إنشاء الاختصار بنجاح!", 64, "Crypto Trading"

Set oShortcut = Nothing
Set WshShell = Nothing
Set fso = Nothing
