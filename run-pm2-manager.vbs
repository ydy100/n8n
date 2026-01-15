Set WshShell = CreateObject("WScript.Shell")
' 현재 디렉토리 경로 확보
strPath = WshShell.CurrentDirectory & "\pm2-manager.ps1"
' 0: 창 숨김, False: 종료를 기다리지 않음
WshShell.Run "powershell.exe -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File """ & strPath & """", 0, False
