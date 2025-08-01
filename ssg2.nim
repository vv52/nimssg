import std/streams, std/tables, std/strbasics

proc generatePage(templateFile: string, contentFile: string, outfile: string): string
proc importContent(contentFile: string): Table[string, string]
proc main(): void

proc generatePage(templateFile: string, contentFile: string, outfile: string): string =
  var sTemplateFile = newStringStream(readFile(templateFile))
  var sOutstr = newStringStream()
  var sContent = newStringStream()
  var isContent : bool = false
  var buffer: string
  var content : Table[string, string] = importContent(contentFile)

  while not sTemplateFile.atEnd():
    sTemplateFile.peekStr(2, buffer)
    if not isContent:
      if buffer == "<%":
        isContent = true
        try: discard sTemplateFile.readStr(2)
        except: discard
      else:
        try: sOutstr.write($sTemplateFile.readStr(1))
        except: discard
    else:
      if buffer == "%>":
        isContent = false
        try:
          discard sTemplateFile.readStr(2)
          sContent.setPosition(0)
          var contentTag : string = $sContent.readAll()
          contentTag.strip()
          sOutstr.write($content[contentTag])
          sContent = newStringStream()
        except: discard
      else:
        try: sContent.write($sTemplateFile.readStr(1))
        except: discard
  sOutstr.setPosition(0)
  result = sOutstr.readAll()
  sOutstr.setPosition(0)
  syncio.writeFile(outfile, sOutstr.readAll())
  sTemplateFile.close()
  sOutstr.close()

proc importContent(contentFile: string): Table[string, string] =
  var sContent = newStringStream(readFile(contentFile))
  var title : string = sContent.readLine()
  var body : string = sContent.readAll()
  result = {"TITLE": title, "BODY": body}.toTable

proc main =
  echo generatePage("index.tmpl", "index.md", "index.html")

when isMainModule:
  main()
