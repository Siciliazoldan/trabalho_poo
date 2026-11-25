@echo off
title Engrenar - Conectar ao MySQL
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0iniciar.ps1" -Apache
if errorlevel 1 pause
