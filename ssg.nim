import std/streams, std/tables, std/strbasics, std/os, std/sequtils

proc getPosts(): seq[string]
proc generatePage(templateFile: string, contentFile: string, outfile: string, isPost: bool): string
proc importContent(contentFile: string, isPost: bool): Table[string, string]
proc main(): void

proc getPosts(): seq[string] =
  result = toSeq(walkFiles("posts/*.md"))

proc generatePage(templateFile: string, contentFile: string, outfile: string, isPost: bool): string =
  var sTemplateFile = newStringStream(readFile(templateFile))
  var sOutstr = newStringStream()
  var sContent = newStringStream()
  var isContent : bool = false
  var buffer: string
  var content : Table[string, string] = importContent(contentFile, isPost)

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

proc importContent(contentFile: string, isPost: bool): Table[string, string] =
  var sContent = newStringStream(readFile(contentFile))
  if isPost:
    var title : string = sContent.readLine()
    var date : string = sContent.readLine()
    var body : string = sContent.readAll()
    result = {"TITLE": title, "DATE": date, "BODY": body}.toTable
  else:
    var title : string = sContent.readLine()
    var body : string = sContent.readAll()
    result = {"TITLE": title, "BODY": body}.toTable

proc main =
  for post in getPosts():
    echo generatePage("templates/index.tmpl", post, "public/" & post, true)
  echo generatePage("templates/index.tmpl", "pages/index.md", "public/index.html", false)

when isMainModule:
  main()
