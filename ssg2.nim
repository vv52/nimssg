import std/os, std/streams, std/tables
import std/strutils, std/strformat
import std/sequtils, std/sugar
import markdown, dekao

proc setup() : void
proc getPages() : seq[string]
proc getPosts() : seq[string]
proc generateHead(content_title: string) : string
proc generateFooter(email_address: string) : string
proc generatePage() : string
proc importContent(content_file : string) : (Table[string, string], string)
proc main() : void

proc setup() : void =
  echo "Checking prerequisite directories:"
  if existsOrCreateDir("pages/"): echo "  Pages \u2713"
  else: echo "  Pages directory not found\n    Creating pages directory...\n    Pages \u2713"
  if existsOrCreateDir("posts/"): echo "  Posts \u2713"
  else: echo "  Posts directory not found\n    Creating posts directory...\n    Posts \u2713"
  if existsOrCreateDir("public/"): echo "  Public \u2713"
  else: echo "  Public directory not found\n    Creating public directory...\n    Public \u2713"
  if existsOrCreateDir("public/posts/"): echo "  Public/posts \u2713"
  else: echo "  Public/posts directory not found\n    Creating public/posts directory...\n    Public \u2713"

proc getPages() : seq[string] =
  let pagePaths = toSeq(walkFiles("pages/*.md"))
  result = pagePaths.map(s => s.split('/')[1])

proc getPosts() : seq[string] =
  result = toSeq(walkFiles("posts/*.md"))

proc generateHead(content_title: string) : string =
  result = render:
    head:
      meta: charset "utf-8"
      meta: name "viewport"; content "width=device-width, initial-scale=1.0"
      meta: httpEquiv "X-UA-Compatible"; content "ie=edge"
      link: rel "stylesheet"; href "https://cdn.simplecss.org/simple.min.css"
      link: rel "stylesheet"; href "custom.css"
      link: rel "icon"; href "./favicon.ico"; ttype "image/x-icon"
      title: say content_title

proc generateHeader() : string =
  result = render:
    header:
      nav:
        a: href "https://badslime.xyz"; class "current"; say "Home"
        a: href "https://github.com/vv52"; say "github"
        a: href "https://vexingvoyage.itch.io"; say "itch.io"
      h1: say "Welcome to my website!"
      p: say "Tagline or something idk"

proc generateFooter(email_address: string) : string =
  result = render:
    footer:
      p:
        a: href fmt"mailto:{email_address}"; say email_address

proc generatePage() : string =
  let imported_content = importContent("pages/index2.md")
  let tags : Table[string, string] = imported_content[0]
  let content : string = imported_content[1]
  result = fmt"""<!DOCTYPE html>
                 <html lang="en">
                 {generateHead(tags["title"])}
                 <body>{generateHeader()}
                 <main>{content}</main>
                 {generateFooter("vanjavenezia@gmail.com")}
                 </body></html>"""

proc importContent(content_file : string) : (Table[string, string], string) =
  let content = newStringStream(readFile(content_file))
  var isFrontMatter : bool = false
  var tags : Table[string, string] = initTable[string, string]()
  var body : string = """"""
  var buffer : string = ""
  buffer = content.readLine()
  if buffer == "---": isFrontMatter = true
  while isFrontMatter:
    buffer = content.readLine()
    if buffer == "---": isFrontMatter = false
    else: tags[buffer.split(':')[0].strip()] = buffer.split(':')[1].strip()
  body = markdown(content.readAll())
  result = (tags, body)

proc main =
#  setup()
#  for page in getPages():
#    echo generatePage("index.html", page, page, false)
#  for post in getPosts():
#    echo generatePage("index.html", post, post, true
# proc generateHeader() : string
#  echo generateHead("My Title")
  writeFile("test.html", generatePage())

when isMainModule:
  main()
