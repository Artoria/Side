@echo off
setlocal
pushd %~dp0
cscript /nologo Side\pre\runner.vbs install.vbs
pushd %userprofile%\SendTo\Side
attrib /d /s +r "%userprofile%\SendTo\Side"
attrib /d /s +r "%userprofile%\SendTo\Side\*"
attrib +h "%userprofile%\SendTo\Side\icon"
attrib +h "%userprofile%\SendTo\Side\pre"
attrib +h "%userprofile%\SendTo\Side\src"
attrib +h "%userprofile%\SendTo\Side\common"
attrib /s +r +h +s Desktop.ini
popd
gpupdate /force /wait:0
endlocal
