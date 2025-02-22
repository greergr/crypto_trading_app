@echo off
echo Creating desktop shortcut...

:: Create a shortcut on the desktop
powershell -Command "$shell = New-Object -ComObject WScript.Shell; $shortcut = $shell.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Crypto Trading Bot.lnk'); $shortcut.TargetPath = 'powershell.exe'; $shortcut.Arguments = '-WindowStyle Hidden -ExecutionPolicy Bypass -File ""%~dp0run_app.ps1""'; $shortcut.WorkingDirectory = '%~dp0'; $shortcut.WindowStyle = 7; $shortcut.IconLocation = '%SystemRoot%\System32\SHELL32.dll,70'; $shortcut.Save()"

echo تم إنشاء اختصار على سطح المكتب
pause
