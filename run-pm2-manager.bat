@echo off
pushd "%~dp0"
echo n8n PM2 Manager is starting...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\pm2-manager.ps1"
if %errorlevel% neq 0 pause