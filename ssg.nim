import std/os, std/times, std/streams, std/tables
import std/strutils, std/strformat
import std/sequtils, std/sugar
import markdown, dekao

proc setup() : void
proc build() : void
proc initDistDir() : void
proc getPages() : seq[string]
proc getPosts() : seq[string]
proc generateHead(content_title: string) : string
proc generateHeader(content_title: string, content_description: string = "") : string
proc generateFooter(email_address: string) : string
proc generatePage(page_path: string) : string
proc generatePost(post_path: string) : string
proc importContent(content_file : string) : (Table[string, string], string)
proc main() : void

proc setup() : void =
  echo "Checking prerequisite directories:"
  if existsOrCreateDir("pages/"): echo "  Pages \u2713"
  else: echo "  Pages directory not found\n    Creating pages directory...\n    Pages \u2713"
  if existsOrCreateDir("posts/"): echo "  Posts \u2713"
  else: echo "  Posts directory not found\n    Creating posts directory...\n    Posts \u2713"

proc build() : void =
  initDistDir()
  for page in getPages():
    # maybe render index.html to root but all else to pages?
    let path : string = fmt".dist/{page.split('.')[0].split('/')[1]}.html"
    writeFile(path, generatePage(page))
  for post in getPosts():
    let path : string = fmt".dist/{post.split('.')[0]}.html"
    writeFile(path, generatePost(post))
  if fileExists("custom.css"):
    copyFileToDir("custom.css", ".dist/")

proc initDistDir() : void =
  removeDir(".dist/")
  createDir(".dist/")
#  createDir(".dist/pages/")
  createDir(".dist/posts/")

proc getPages() : seq[string] =
  result = toSeq(walkFiles("pages/*.md"))

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

proc generateHeader(content_title: string, content_description: string = "") : string =
  result = render:
    header:
      nav:
        a: href "https://badslime.xyz"; class "current"; say "Home"
        a: href "https://github.com/vv52"; say "github"
        a: href "https://vexingvoyage.itch.io"; say "itch.io"
      h1: say content_title
      p: say content_description

proc generateFooter(email_address: string) : string =
  result = render:
    footer:
      p:
        a: href fmt"mailto:{email_address}"; say email_address

proc generatePage(page_path: string) : string =
  let imported_content = importContent(page_path)
  var tags : Table[string, string] = imported_content[0]
  let content : string = imported_content[1]
  if tags.hasKeyOrPut($"description", $""):
    discard
  result = fmt"""<!DOCTYPE html>
                 <html lang="en">
                 {generateHead(tags["title"])}
                 <body>{generateHeader(tags["title"], tags["description"])}
                 <main>{content}</main>
                 {generateFooter("vanjavenezia@gmail.com")}
                 </body></html>"""

proc generatePost(post_path: string) : string =
  let imported_content = importContent(post_path)
  let tags : Table[string, string] = imported_content[0]
  let content : string = imported_content[1]
  let raw_post_date = parse(tags["date"], "yyyyMMdd")
  let post_date = raw_post_date.format("d MMMM yyyy")
  result = fmt"""<!DOCTYPE html>
                 <html lang="en">
                 {generateHead(tags["title"])}
                 <body>{generateHeader(tags["title"], post_date)}
                 <main>{content}</main>
                 {generateFooter("vanjavenezia@gmail.com")}
                 </body></html>"""

proc importContent(content_file : string) : (Table[string, string], string) =
  let content = newStringStream(readFile(content_file))
  var is_frontmatter : bool = false
  var tags : Table[string, string] = initTable[string, string]()
  var body : string = """"""
  var buffer : string = ""
  buffer = content.readLine()
  if buffer == "---": is_frontmatter = true
  while is_frontmatter:
    buffer = content.readLine()
    if buffer == "---": is_frontmatter = false
    else: tags[buffer.split(':')[0].strip()] = buffer.split(':')[1].strip()
  body = markdown(content.readAll())
  result = (tags, body)

proc main =
  setup()
  build()

when isMainModule:
  main()
