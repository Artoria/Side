@echo off
setlocal
pushd %~dp0
cscript /nologo Side\pre\runner.vbs install.vbs -nocopy
gpupdate /force /wait:0
endlocal
