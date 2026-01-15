Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "cmd /c ""C:\Users\user\AppData\Roaming\npm\pm2.cmd"" resurrect", 0, False
