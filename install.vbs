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


sub readlang
  if not currentLocale is nothing then
    global "currentLocale", "resource(GetUILanguage)"
    ExecuteGlobal read(".\Lang\1033.vbs")
    ExecuteGlobal read(".\Lang\2052.vbs")
  end if
end sub
sub L10N
  [each] currentLocale, [lambda](array("ren root+arg, root+env(arg)"))
end sub

function format(path, hash)
'Todo: make this more flexible  
  [gsub!] path, "\$\(root\)", root               'SendTo\Side
  [gsub!] path, "\$\(lroot\)", localroot         '(install)\Side
  [gsub!] path, "\$\(localroot\)", localroot     'ditto
  [gsub!] path, "\$\(lnk\)", root+output+".lnk"  'shortcut entry
  [gsub!] path, "\$\(file\)", hash("file")       'side file
  [gsub!] path, "\$\(runner\)", hash("runner")   'runner.vbs
  [gsub!] path, "\$\(exe\)", hash("exe")         'main program
end function

function make_pre(env, arg)
  if strslice(arg, -5, -1) <> ".side" then
     exit function
  end if
  txt = readlines(arg)
  icon   = trim(strslice(txt(0), 1, -1))
  output = trim(strslice(txt(1), 1, -1))
  if ubound(txt) >= 2 then
    shelltype = trim(strslice(txt(2), 1, -1))
  end if
  if ubound(txt) >= 3 then
    arguments = trim(strslice(txt(3), 1, -1))
  end if

  if [=~](shelltype, "^!", nothing) then
     runfile = [gsub](shelltype, "^!", "")
     myarg  = "$(file)"
  else
     runfile = "wscript.exe"    
     myarg = "$(runner) $(file)"
  end if

  if [=~](arguments, "^!", nothing) then
     myarg = [gsub](arguments, "^!", "")
  end if

  dim hash
  set hash = CreateObject("Scripting.Dictionary")
  runner = localroot + "pre\runner.vbs"
  hash("file") =  [string](arg)
  hash("runner") = [string](runner)
  hash("exe") = [string](runfile)

  makefolder [File.dirname](root + output + ".lnk"),[File.dirname](localroot + output + ".lnk")
  set outlnk = shell.CreateShortcut(root + output + ".lnk")
  iconfile = [gsub](icon, ",\d+$", "")
  if [=~](iconfile, "\.ico$", nothing) then 
    iconfile = localiconroot + iconfile
  else
    iconfile = icon
  end if

  format runfile, hash
  format myarg, hash
  format iconfile, hash

  outlnk.IconLocation = iconfile
  outlnk.TargetPath = runfile
  outlnk.WorkingDirectory=localroot + ".."
  outlnk.Arguments = myarg
  outlnk.save
  p join(array("Rewrite",runfile, myarg, iconfile), " ")
  vimoutput = output
  vimoutput=[gsub] (vimoutput, "\.", "\.")
  vimoutput=[gsub] (vimoutput, "\\", ".")
  vimoutput=[gsub] (vimoutput, " ", "\ ")
  dim i
  for each i in currentLocale
    vimoutput = replace(vimoutput, i, currentLocale(i))
    output    = replace(output, i, currentLocale(i))
  next
  append "output.vim", join(array("menu ", vimoutput, " ", ":! start "" "" ", [string](root+output+".lnk"), " %:p:h<CR>", vbcrlf))
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
readlang
MakeShortcutsForPre
L10N
