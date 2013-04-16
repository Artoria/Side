  vimoutput = output
  vimoutput=[gsub] (vimoutput, "\.", "\.")
  vimoutput=[gsub] (vimoutput, "\\", ".")
  vimoutput=[gsub] (vimoutput, " ", "\ ")
  dim i
  uoutput = output
  for each i in currentLocale
    vimoutput = replace(vimoutput, i, currentLocale(i))
    uoutput    = replace(uoutput, i, currentLocale(i))
  next
  append "output.vim", join(array("menu ", vimoutput, " ", ":! start "" "" ", [string](root+uoutput+".lnk"), " %:p:h<CR>", vbcrlf))