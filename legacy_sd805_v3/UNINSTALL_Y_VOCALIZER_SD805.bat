@echo off
setlocal
title L4D2VR sd805 - Y Vocalizer v3.0 - Uninstall
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0UNINSTALL_Y_VOCALIZER_SD805.ps1"
if errorlevel 1 (
  echo.
  echo Desinstallation echouee.
  pause
  exit /b 1
)
endlocal
