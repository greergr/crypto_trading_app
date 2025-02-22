$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Crypto Trading.lnk")
$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = "`"$PSScriptRoot\launcher.vbs`""
$Shortcut.IconLocation = "%SystemRoot%\System32\imageres.dll,108"  # أيقونة جميلة للتداول
$Shortcut.Description = "Crypto Trading Application"
$Shortcut.WorkingDirectory = $PSScriptRoot
$Shortcut.Save()

# إنشاء ملف launcher.vbs
@"
Option Explicit

' إنشاء الكائنات المطلوبة
Dim WshShell, fso, appPath, serverPath, objExec

Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' تحديد المسارات
appPath = "$PSScriptRoot"
serverPath = appPath & "\server.py"

' إظهار شاشة البداية
WshShell.Popup "جاري تشغيل منصة التداول...", 2, "Crypto Trading", 64

' إيقاف أي نسخة سابقة من الخادم
On Error Resume Next
WshShell.Run "taskkill /F /IM pythonw.exe", 0, True
WScript.Sleep 1000
On Error GoTo 0

' تشغيل الخادم في الخلفية
Set objExec = WshShell.Exec("pythonw """ & serverPath & """")

' انتظار لحظة للتأكد من تشغيل الخادم
WScript.Sleep 2000

' فتح المتصفح
WshShell.Run "http://localhost:5000", 1

' تنظيف
Set objExec = Nothing
Set WshShell = Nothing
Set fso = Nothing
"@ | Out-File -FilePath "$PSScriptRoot\launcher.vbs" -Encoding UTF8

Write-Host "تم إنشاء الاختصار بنجاح على سطح المكتب!"
