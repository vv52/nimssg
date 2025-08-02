import std/streams, std/tables, std/strbasics, std/strformat, std/os, std/sequtils, markdown

proc setup(): void
proc getPosts(): seq[string]
proc generatePage(templateFile: string, contentFile: string, outfile: string, isPost: bool): string
proc importContent(contentFile: string, isPost: bool): Table[string, string]
proc main(): void

proc setup(): void =
  echo "Checking prerequisite directories:"
  if existsOrCreateDir("pages/"): echo "  Pages \u2713"
  else: echo "  Pages directory not found\n    Creating pages directory...\n    Pages \u2713"
  if existsOrCreateDir("posts/"): echo "  Posts \u2713"
  else: echo "  Posts directory not found\n    Creating posts directory...\n    Posts \u2713"
  if existsOrCreateDir("public/"): echo "  Public \u2713"
  else: echo "  Public directory not found\n    Creating public directory...\n    Public \u2713"
  if existsOrCreateDir("public/posts/"): echo "  Public/posts \u2713"
  else: echo "  Public/posts directory not found\n    Creating public/posts directory...\n    Public \u2713"
  if existsOrCreateDir("templates/"): echo "  Templates \u2713"
  else: echo "  Templates directory\n    Creating templates directory...\n    Templates \u2713"

proc getPosts(): seq[string] =
  result = toSeq(walkFiles("posts/*.md"))

proc generatePage(templateFile: string, contentFile: string, outfile: string, isPost: bool): string =
  var sTemplateFile = newStringStream()
  if isPost:
    sTemplateFile = newStringStream(readFile("templates/post.tmpl"))
  else:
    sTemplateFile = newStringStream(readFile(fmt"templates/{templateFile}"))
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
  syncio.writeFile(fmt"public/{outfile}", sOutstr.readAll())
  sTemplateFile.close()
  sOutstr.close()

proc importContent(contentFile: string, isPost: bool): Table[string, string] =
  var sContent = newStringStream(readFile(contentFile))
  if isPost:
    var title : string = sContent.readLine()
    var date : string = sContent.readLine()
    var body : string = markdown(sContent.readAll())
    result = {"TITLE": title, "DATE": date, "BODY": body}.toTable
  else:
    var title : string = sContent.readLine()
    var body : string = markdown(sContent.readAll())
    result = {"TITLE": title, "BODY": body}.toTable

proc main =
  setup()
  for post in getPosts():
    echo generatePage("index.tmpl", post, post, true)
  echo generatePage("index.tmpl", "pages/index.md", "index.html", false)

when isMainModule:
  main()
