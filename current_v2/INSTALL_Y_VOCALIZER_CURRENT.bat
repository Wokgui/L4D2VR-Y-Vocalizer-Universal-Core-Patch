@echo off
setlocal
title L4D2VR - Y Vocalizer Shortcut v2.0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL_Y_VOCALIZER_CURRENT.ps1"
if errorlevel 1 (
    echo.
    echo Installation echouee.
    pause
    endlocal
    exit /b 1
)

if exist "%~dp0FIX_QUEST_HEIGHT_SHORTCUTS.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0FIX_QUEST_HEIGHT_SHORTCUTS.ps1"
    if errorlevel 1 (
        echo.
        echo Le vocalizer est installe, mais le correctif de hauteur Quest a echoue.
        pause
        endlocal
        exit /b 1
    )
)

endlocal
