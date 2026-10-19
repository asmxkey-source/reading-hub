@echo off
rem Kakao export txt -> sapiens/chat.txt -> git push
rem Double-click, or drag a KakaoTalk_*.txt file onto this bat.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\update-chat.ps1" -Book sapiens -File "%~1"
echo.
pause
