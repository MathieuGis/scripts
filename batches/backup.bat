set datum=%date:/=%

net use X: \\10.114.97.87\backup_001\10.114.97.19

forfiles /P X: /S /d -7 /C  "cmd /c del /F /Q @file"

ROBOCOPY X:\ X:\ /S /MOVE

net use X: /delete

mkdir "\\10.114.97.87\backup_001\10.114.97.19\%datum%"

robocopy C:\Backup "\\10.114.97.87\backup_001\10.114.97.19\%datum%" /S /r:3 /w:3

