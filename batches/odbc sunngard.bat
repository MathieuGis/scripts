@echo off
set /p tech=technr?     
set /p custDB=DB link(in mail)?        
SET /p PASS=password (in mail)?    


echo Windows Registry Editor Version 5.00> %tech%.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources]>> %tech%.reg
echo "%tech%TRANSICS"="SQL Anywhere 10">> %tech%.reg
echo [HKEY_LOCAL_MACHINE\SOFTWARE\ODBC\ODBC.INI\%tech%TRANSICS]>> %tech%.reg
echo "Driver"="C:\\Program Files\\SQL Anywhere 10\\win32\\dbodbc10.dll">> %tech%.reg
echo "UID"="THIRDPARTY">> %tech%.reg
echo "PWD"="%PASS%">> %tech%.reg
echo "Description"=" ">> %tech%.reg
echo "DatabaseName"="%tech%transics">> %tech%.reg
echo "EngineName"="%custDB%">> %tech%.reg
echo "AutoStop"="NO">> %tech%.reg
echo "Integrated"="NO">> %tech%.reg
echo "Debug"="NO">> %tech%.reg
echo "DisableMultiRowFetch"="NO">> %tech%.reg
echo "CommLinks"="TCPIP{HOST=82.195.137.133;SERVERPORT=1%tech%;DOBROADCAST=NO}">> %tech%.reg
echo "Compress"="NO">> %tech%.reg
echo "ConnectionName"="TRANSICS SERVER">> %tech%.reg

pause

%tech%.reg

pause

echo yes|del %tech%.reg



