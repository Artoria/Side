  makefolder [File.dirname](root + output + ".lnk"),[File.dirname](localroot + output + ".lnk")
  set outlnk = shell.CreateShortcut(root + output + ".lnk")
  outlnk.IconLocation = iconfile
  outlnk.TargetPath = runfile
  outlnk.WorkingDirectory=localroot + ".."
  outlnk.Arguments = myarg
  outlnk.save
