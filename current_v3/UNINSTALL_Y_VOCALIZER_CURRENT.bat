@echo off
setlocal
title L4D2VR - Y Vocalizer Shortcut v3.0 - Uninstall
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0UNINSTALL_Y_VOCALIZER_CURRENT.ps1"
if errorlevel 1 (
    echo.
    echo Desinstallation echouee.
    pause
)
endlocal
