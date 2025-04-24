# script to create .exe file for monitoring tool

Install-Module PS2EXE -Scope CurrentUser

PS2EXE -inputfile monitor.ps1 -outputfile monitor.exe -noConsole
