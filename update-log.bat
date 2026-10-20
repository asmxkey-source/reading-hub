@echo off
rem Solo book: open log.txt in Notepad, then git push
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\update-log.ps1"
echo.
pause
