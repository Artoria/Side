global "fso", [class]("Scripting.FileSystemObject")
global "sa",  [class]("Shell.Application")
global "shell",  [class]("WScript.Shell")
global "resource", ID_HASH
global "resource(2052)", ID_HASH
global "resource(1033)", ID_HASH
global "root", [string](shell.specialFolders("SendTo")+"\Side\") 
global "iconroot", [string](root+"\icon\") 
global "localiconroot", [string]("icon\")

sub CopyMain
  Copy folder(".\Side").path, specialFolder(ID_SENDTO)
end sub

sub L10N
  global "currentLocale", "resource(GetUILanguage)"
  ExecuteGlobal read(".\Lang\1033.vbs")
  ExecuteGlobal read(".\Lang\2052.vbs")
  [each] currentLocale, [lambda](array("ren root+arg, root+env(arg)"))
end sub

function make_pre(env, arg)
  if strslice(arg, -5, -1) <> ".side" then
     exit function
  end if
  txt = readlines(arg)
  icon   = trim(strslice(txt(0), 1, -1))
  output = trim(strslice(txt(1), 1, -1))
  set outlnk = shell.CreateShortcut(root + output + ".lnk")
  iconfile = [gsub](icon, ",\d+$", "")
  if [=~](iconfile, "\.ico$", nothing) then
    fso.CopyFile localiconroot + iconfile,iconroot + iconfile
  end if
  outlnk.IconLocation = iconroot + icon
  outlnk.TargetPath = "wscript.exe" 
  runner = root + "pre\runner.vbs"
  outlnk.Arguments = [string](runner) + " " + [string](arg)
  outlnk.save
end function

sub MakeShortcutsForPre
  [each] fso.Getfolder(root+"pre").Files, getref("make_pre")
end sub

sub Clear
  if [exist?](strslice(root, 0, -2)) then
    fso.deletefolder strslice(root, 0, -2), true
  end if
end sub


if (argc > 1) then
  if argv(0) <> "-nocopy" then
     Clear
     CopyMain
  end if
else
  Clear
  CopyMain
end if
MakeShortcutsForPre
L10N
