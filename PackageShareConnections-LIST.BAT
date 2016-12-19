ECHO %DATE% %TIME% > "%~DP0PackageShareConnections-LIST.LOG"
PowerShell.exe "%~DP0PackageShareConnections-LIST.PS1" > "%~DP0PackageShareConnections-LIST.LOG"