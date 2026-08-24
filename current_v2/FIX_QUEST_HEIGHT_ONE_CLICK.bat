@echo off
setlocal
title L4D2VR / Quest 3 - Height Safety Fix
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0FIX_QUEST_HEIGHT_SHORTCUTS.ps1"
if errorlevel 1 (
    echo.
    echo Correctif echoue.
    pause
)
endlocal
