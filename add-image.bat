@echo off
rem Attach images to a reading log entry: drag image files onto this bat, or double-click to pick files.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\add-image.ps1" %*
echo.
pause
