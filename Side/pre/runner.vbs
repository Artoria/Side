'--------------------------Meta-----------------------------
sub global(a,b)
  ExecuteGlobal "[$_] = array(" & b & ")"
  if (vartype([$_](0)) and 9) = 9 then
     ExecuteGlobal "set " & a & " = [$_](0)"
  else
     ExecuteGlobal  a & " = [$_](0)"
  end if
end sub



function [class](name)
  [class] = "CreateObject(""" & name & """)"
end function

function [string](name)
  [string] = """" + replace(name, """", """""") + """"
end function

ID_HASH        = [class]("Scripting.Dictionary")
ID_USERPROFILE = &H28
ID_SENDTO      = &H9

'----------------------Utility------------------------------
function argv(n)
 if n = -1 then
   argv = WScript.ScriptFullName
 else
   argv = WScript.Arguments(n + loadlevel + 1)
 end if
end function

function argc
  argc = WScript.Arguments.length
end function

function Copy(src, destfolder)
 WScript.Echo "Copying Files From " + src + " To " + destfolder
  destfolder.copyHere src, 64
end function

function mkdir(dir)
  fso.CreateFolder dir
end function

function mklines(a)
  mklines = join(a, vbcrlf)
end function

function specialFolder(a)
  set specialFolder = sa.NameSpace(a)
end function

function folder(a)
  set folder = fso.getFolder(a)
end function
 
function read(a)
  dim f
  set f = fso.GetFile(a).openAsTextStream(1)
  read = f.ReadAll
  f.Close
end function

function load(a)
  loadlevel = loadlevel + 1
  ExecuteGlobal read(a)
  loadlevel = loadlevel - 1
end function

function write(a, b)
  dim f
  set f = fso.CreateTextFile(a,true)
  call f.Write(b)
  f.Close
end function

function append(a, b)
  dim f
  if not [exist?](a) then
    write a,b
  else
    set f = fso.Getfile(a).OpenAsTextStream(8)
    call f.Write(b)
    f.Close
  end if
end function

function readlines(a)
  readlines = split(read(a), vbcrlf)
end function

function strslice(a, b, c)
  if len(a) = 0 then
    strslice = ""
    exit function
  end if
  dim r, s : r = b: s = c
  r = r mod len(a)
  if r < 0 then 
    r = r + len(a)
  end if

  s = s  mod len(a)
  if s <= 0 then 
    s = s + len(a) + 1
  end if
  strslice = mid(a, r+1, s)
end function

function [file?](a)
  [file?]=fso.FileExists(a)
end function

function [folder?](a)
  [folder?]=fso.FolderExists(a)
end function

function [exist?](a)
  [exist?] = false
  if [file?](a) then
    [exist?] = true
  end if
  if [folder?](a) then
   [exist?]=true
  end if
end function


function [regex](a)
  set [regex] = new Regexp
  [regex].pattern = a
end function

function [gsub](a, b, c)
  dim u
  set u = [regex](b)
  u.global = true
  [gsub] = u.replace(a, c)
end function

function [gsub!](a, b, c)
  dim u
  set u = [regex](b)
  u.global = true
  a = u.replace(a, c)
  [gsub!] = a 
end function


function [=~](a, b, g)
  dim u, m
  set u = [regex](b)
  if g is nothing then
    [=~] = u.test(a)
    exit function
  end if

  set m = u.execute(a)
  if g > 0 then
     [=~] = m(0).submatches(g-1)    
  else
    [=~] = m(0).value
  end if
end function



function [File.dirname](a)
  [File.dirname] = [gsub](a, "[^\\]+\\?$", "")
end function

function [File.basename](a)
  [File.basename] = [=~](a, "([^\\]+)\\?$", 1)
end function

function [File.basename 2](a, b)
  dim v, u
  u = b
  v = [=~](a, "([^\\]+)\\?$", 1)
  u = [gsub](u, "\.", "\.")
  u = [gsub](u, "\*", ".*")  
  [File.basename 2] = [gsub](v, u, "")
end function


function substr(a, b, c)
  if len(a) = 0 then
    strslice = ""
    exit function
  end if
  dim r, s : r = b: s = c
  r = r mod len(a)
  if r < 0 then 
    r = r + len(a)
  end if
  s = s mod len(a)
  if s < 0 then 
    s = s + len(a)
  end if

  substr = mid(a, r+1, s)
end function

function [`](a)
  dim exec
  set exec = shell.exec(a)
  [`] = exec.StdOut.ReadAll
  set exec=nothing  
end function

function system(a)
  call shell.run(a, 4, true)
end function

function ren(a, b)
  p "Renaming " & a & " to " & b
  if fso.FileExists(a) then
    fso.moveFile a, b
  elseif fso.FolderExists(a) then
    fso.moveFolder a,b
  else
    p "..Nothing happend"
  end if
end function

function p(a)
  WScript.StdOut.WriteLine a
end function

function [each](a, b)
  for each i in a
    call b(a, i)
  next
end function

function [each with object](a, obj, b)
  for each i in a
    call b(a, obj, i)
  next
end function


LambdaCount = 0
class LambdaVoid
  dim fn
  public function setup(a)
    LambdaCount = LambdaCount + 1
    name = "last" & LambdaCount & "__"
    executeglobal join(array("function " + name + "(env, arg)", a, "end function"), vbCrLf)
    set fn = getref(name)
    set setup = Me
  end function

  public default property get hello(env, arg)  
    call Me.fn(env, arg)
  end property
  
end class

function [lambda](a)
  set [lambda] = (new LambdaVoid).setup(join(a, vbcrlf))
end function

function [browse folder](prompt, base)
  [browse folder] = sa.BrowseForFolder(0, prompt, &H10 or &H40, 0).self.path
end function

'--------------------------Main-----------------------------
global "fso", [class]("Scripting.FileSystemObject")
global "sa",  [class]("Shell.Application")
global "shell",  [class]("WScript.Shell")
global "resource", ID_HASH
global "resource(2052)", ID_HASH
global "resource(1033)", ID_HASH
global "currentLocale", "resource(GetUILanguage)"
global "root", [string](shell.specialFolders("SendTo")+"\Side\") 
global "localroot", [string](folder("Side").path + "\")  
global "iconroot", [string](root+"\icon\") 
global "localiconroot", [string](localroot+"\..\icon\") 
global "loadlevel", "0"
ExecuteGlobal read(WScript.Arguments(0))
