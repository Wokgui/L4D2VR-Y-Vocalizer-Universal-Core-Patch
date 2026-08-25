@echo off
setlocal
title L4D2VR sd805 - Y Vocalizer v3.0
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL_Y_VOCALIZER_SD805.ps1"
if errorlevel 1 (
  echo.
  echo Installation echouee.
  pause
  exit /b 1
)
endlocal
