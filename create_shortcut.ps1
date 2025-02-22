$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Crypto Trading App.lnk")
$Shortcut.TargetPath = "wscript.exe"
$Shortcut.Arguments = "`"$PSScriptRoot\launcher.vbs`" `"$PSScriptRoot\run_app.bat`""
$Shortcut.WorkingDirectory = "$PSScriptRoot"
$Shortcut.IconLocation = "%SystemRoot%\System32\imageres.dll,108"
$Shortcut.Save()
