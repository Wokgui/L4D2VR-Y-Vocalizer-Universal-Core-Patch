@echo off
setlocal
title L4D2VR - Y Vocalizer Shortcut v2.0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL_Y_VOCALIZER_CURRENT.ps1"
if errorlevel 1 (
    echo.
    echo Installation echouee.
    pause
)
endlocal
