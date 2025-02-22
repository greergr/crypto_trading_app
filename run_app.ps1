$Host.UI.RawUI.WindowTitle = "Crypto Trading Bot"
$Host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(0, 0)
Set-Location $PSScriptRoot
Start-Process flutter -ArgumentList "run", "-d", "windows" -WindowStyle Hidden
