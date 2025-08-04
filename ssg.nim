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
      link: rel "stylesheet"; href "/custom.css"
      link: rel "icon"; href "./favicon.ico"; ttype "image/x-icon"
      title: say content_title

proc generateHeader(content_title: string, content_description: string = "") : string =
  result = render:
    header:
      nav:
        a: href "https://badslime.xyz"; class "current"; say "Home"
        a: href "https://github.com/vv52"; say "<svg class=\"icon\" viewBox=\"0 0 32 32\"><path d=\"M16 0.395c-8.836 0-16 7.163-16 16 0 7.069 4.585 13.067 10.942 15.182 0.8 0.148 1.094-0.347 1.094-0.77 0-0.381-0.015-1.642-0.022-2.979-4.452 0.968-5.391-1.888-5.391-1.888-0.728-1.849-1.776-2.341-1.776-2.341-1.452-0.993 0.11-0.973 0.11-0.973 1.606 0.113 2.452 1.649 2.452 1.649 1.427 2.446 3.743 1.739 4.656 1.33 0.143-1.034 0.558-1.74 1.016-2.14-3.554-0.404-7.29-1.777-7.29-7.907 0-1.747 0.625-3.174 1.649-4.295-0.166-0.403-0.714-2.030 0.155-4.234 0 0 1.344-0.43 4.401 1.64 1.276-0.355 2.645-0.532 4.005-0.539 1.359 0.006 2.729 0.184 4.008 0.539 3.054-2.070 4.395-1.64 4.395-1.64 0.871 2.204 0.323 3.831 0.157 4.234 1.026 1.12 1.647 2.548 1.647 4.295 0 6.145-3.743 7.498-7.306 7.895 0.574 0.497 1.085 1.47 1.085 2.963 0 2.141-0.019 3.864-0.019 4.391 0 0.426 0.288 0.925 1.099 0.768 6.354-2.118 10.933-8.113 10.933-15.18 0-8.837-7.164-16-16-16z\"></path></svg>GitHub"
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
