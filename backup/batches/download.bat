@echo off

:start

ECHO Y |DEL C:\Users\mathieug\Documents\move.xlsx

pause

ECHO open dsinferno.synology.me> temp.txt
ECHO mathieu>> temp.txt
ECHO Inferno1991>> temp.txt
ECHO binary>> temp.txt
ECHO lcd C:\Users\mathieug\Documents>> temp.txt
ECHO cd /home/CloudStation>> temp.txt
ECHO PROMPT>> temp.txt
ECHO get move.xlsx>> temp.txt
ECHO bye>> temp.txt

ftp  -s:temp.txt
del temp.txt

pause