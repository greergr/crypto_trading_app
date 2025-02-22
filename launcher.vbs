Set WShell = CreateObject("WScript.Shell")
WShell.Run """" & WScript.Arguments(0) & """", 0
Set WShell = Nothing
