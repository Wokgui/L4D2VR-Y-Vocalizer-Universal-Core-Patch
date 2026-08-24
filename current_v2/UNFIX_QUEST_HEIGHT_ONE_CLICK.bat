@echo off
setlocal
title L4D2VR / Quest 3 - Desinstaller Height Safety Fix
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0UNFIX_QUEST_HEIGHT_SHORTCUTS.ps1"
if errorlevel 1 (
    echo.
    echo Desinstallation echouee.
    pause
)
endlocal
