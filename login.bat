@echo off
setlocal EnableDelayedExpansion
set current_dir=%cd%
echo %current_dir%

start powershell -noexit -command "cd %current_dir% ; ./autologin.ps1"


REM set /p input=wait