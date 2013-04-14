@echo off
setlocal
pushd %~dp0
cscript /nologo Side\pre\runner.vbs install.vbs
pushd %userprofile%\SendTo\Side
attrib /d /s +r .
attrib /d /s +r .\*
attrib +h icon
attrib +h pre
attrib +h src
attrib +h common
attrib /s +r +h +s Desktop.ini
popd
gpupdate /force /wait:0
endlocal
