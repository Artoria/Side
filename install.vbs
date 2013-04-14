global "fso", [class]("Scripting.FileSystemObject")
global "sa",  [class]("Shell.Application")
global "shell",  [class]("WScript.Shell")
global "resource", ID_HASH
global "resource(2052)", ID_HASH
global "resource(1033)", ID_HASH


function makefolder(a, b)
  if not [exist?](a) then
    if not [exist?]([File.dirname](a)) then
     makefolder [File.dirname](a), [File.dirname](b)
    end if
    if [exist?](b) then
      fso.CopyFolder strslice(b,0,-2), strslice(a,0,-2), true
    end if
  end if
end function

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
  makefolder [File.dirname](root + output + ".lnk"),[File.dirname](localroot + output + ".lnk")
  set outlnk = shell.CreateShortcut(root + output + ".lnk")
  iconfile = [gsub](icon, ",\d+$", "")
  if [=~](iconfile, "\.ico$", nothing) then 
    iconfile = localiconroot + iconfile
  else
    iconfile = icon
  end if
  outlnk.IconLocation = iconfile
  outlnk.TargetPath = "wscript.exe" 
  outlnk.WorkingDirectory=localroot + "\.."
  runner = localroot + "pre\runner.vbs"
  outlnk.Arguments = [string](runner) + " " + [string](arg)
  outlnk.save
end function

sub MakeShortcutsForPre
  [each] fso.Getfolder(localroot+"pre").Files, getref("make_pre")
end sub

sub Clear
  if [exist?](strslice(root, 0, -2)) then
    fso.deletefolder strslice(root, 0, -2), true
  end if
end sub


Clear

MakeFolder root+"icon\", localroot+"icon\"
MakeShortcutsForPre
L10N
