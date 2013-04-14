@echo off
setlocal
pushd %~dp0
cscript /nologo Side\pre\runner.vbs install.vbs
gpupdate /force /wait:0
endlocal
