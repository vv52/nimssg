import std/streams

proc generatePage(templateFile: string, content: string, outfile: string): string
proc main(): void

proc generatePage(templateFile: string, content: string, outfile: string): string =
  var sOutfile = newFileStream(outfile)
  var sTemplateFile = newStringStream(readFile(templateFile))
  var sOutstr = newStringStream()
  var sContent = newStringStream()
  var isContent : bool = false
  var buffer: string

  while not sTemplateFile.atEnd():
    sTemplateFile.peekStr(2, buffer)
    if not isContent:
      if buffer == "<%":
        isContent = true
        try: discard sTemplateFile.readStr(2)
        except: break
      else:
        try: sOutstr.write($sTemplateFile.readStr(1))
        except: break
    else:
      if buffer == "%>":
        isContent = false
        try:
          discard sTemplateFile.readStr(2)
          sContent.write("\n")
        except: break
      else:
        try: sContent.write($sTemplateFile.readStr(1))
        except: break
  sOutstr.setPosition(0)
  result = sOutstr.readAll()
  sOutstr.setPosition(0)
  syncio.writeFile(outfile, sOutstr.readAll())
#  sOutfile.write(sOutstr.readAll())
  sTemplateFile.close()
  sOutstr.close()
  sOutfile.close()

proc main =
  echo generatePage("index.tmpl", "index.md", "index.html")

when isMainModule:
  main()
