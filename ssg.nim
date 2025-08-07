import std/os, std/times, std/streams
import std/strutils, std/strformat
import std/sequtils
import std/algorithm
import markdown, dekao, css_html_minify

type
  Content = object
    path*: string
    web_path*: string
    title*: string
    description*: string
    date*: int
    fdate*: string
    body*: string

proc setup() : void
proc build() : void
proc initDistDir() : void
proc contentCmp(x, y: Content): int
proc getPages() : seq[Content]
proc getPosts() : seq[Content]
proc generateHead(content_title: string) : string
proc generateHeader(page_content: Content) : string
proc generateBlogHeader(page_content: Content) : string
proc generateFooter(email_address: string) : string
proc generatePage(page_content: Content) : string
proc generatePost(post_content: Content) : string
proc generateBlog() : string
proc importContent(content_file : string) : Content
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
    writeFile(fmt".dist/{page.web_path}", minifyHtml(generatePage(page)))
  writeFile(".dist/blog.html", minifyHtml(generateBlog()))
#  if fileExists("simple.min.css"):
#    copyFileToDir("simple.min.css", ".dist/")
  if fileExists("custom.css"):
    copyFileToDir("custom.css", ".dist/")
  if fileExists("favicon.ico"):
    copyFileToDir("favicon.ico", ".dist/")

proc initDistDir() : void =
  removeDir(".dist/")
  createDir(".dist/")
  createDir(".dist/posts/")

proc contentCmp(x, y: Content): int =
  cmp(x.date, y.date)

proc getPages() : seq[Content] =
  let page_paths = toSeq(walkFiles("pages/*.md"))
  var pages : seq[Content]
  for page_path in page_paths:
    pages.add(importContent(page_path))
  result = pages

proc getPosts() : seq[Content] =
  let post_paths = toSeq(walkFiles("posts/*.md"))
  var posts: seq[Content]
  for post_path in post_paths:
    posts.add(importContent(post_path))
  result = posts

proc generateHead(content_title: string) : string =
  result = render:
    head:
      meta: charset "utf-8"
      meta: name "viewport"; content "width=device-width, initial-scale=1.0"
      meta: httpEquiv "X-UA-Compatible"; content "ie=edge"
      link: rel "stylesheet"; href "https://cdn.simplecss.org/simple.min.css"
      #link: rel "stylesheet"; href "/simple.min.css"
      link: rel "stylesheet"; href "/custom.css"
      link: rel "icon"; href "./favicon.ico"; ttype "image/x-icon"
      title: say content_title

proc generateHeader(page_content: Content) : string =
  result = render:
    header:
      nav:
        a: href "/"; class "current"; say "Home"
        a: href "/blog"; say "Blog"
        a: href "https://github.com/vv52"; say "GitHub"
        a: href "https://vexingvoyage.itch.io"; say "itch.io"
      h1: say page_content.title
      p: say page_content.description

proc generateBlogHeader(page_content: Content) : string =
  result = render:
    header:
      nav:
        a: href "/"; say "Home"
        a: href "/blog"; class "current"; say "Blog"
        a: href "https://github.com/vv52"; say "GitHub"
        a: href "https://vexingvoyage.itch.io"; say "itch.io"
      h1: say page_content.title
      if page_content.date != 0:
        p: say page_content.fdate
      p: say page_content.description

proc generateFooter(email_address: string) : string =
  result = render:
    footer:
      p:
        a: href fmt"mailto:{email_address}"; say email_address
      a: href "#top"; say "[Top]"

proc generatePage(page_content: Content) : string =
  result = fmt"""<!DOCTYPE html>
                 <html lang="en">
                 {generateHead(page_content.title)}
                 <body>{generateHeader(page_content)}
                 <main>{page_content.body}</main>
                 {generateFooter("vanjavenezia@gmail.com")}
                 </body></html>"""
                 
proc generatePost(post_content: Content) : string =
  result = fmt"""<!DOCTYPE html>
                 <html lang="en">
                 {generateHead(post_content.title)}
                 <body>{generateBlogHeader(post_content)}
                 <main>{post_content.body}</main>
                 {generateFooter("vanjavenezia@gmail.com")}
                 </body></html>"""

proc generateBlog() : string =
  var posts = getPosts()
  posts.sort(contentCmp, order = SortOrder.Descending)
  var body_content = """"""
  for dated_post in posts:
    writeFile(fmt".dist/{dated_post.web_path}", minifyHtml(generatePost(dated_post)))
    body_content = body_content &
      fmt"""<article><h3><a href="{dated_post.web_path}">{dated_post.title}</a>
      <small><i>{$dated_post.fdate}</i></small></h3>"""
    if dated_post.description != "":
      body_content = body_content & fmt"""<hr />{dated_post.description}</article>"""
    else:
      body_content = body_content & """</article>"""
  var blog : Content
  blog.title = "Blog"
  blog.description = "My blog"
  result = fmt"""<!DOCTYPE html>
                 <html lang="en">
                 {generateHead(blog.title)}
                 <body>{generateBlogHeader(blog)}
                 <main>{body_content}</main>
                 {generateFooter("vanjavenezia@gmail.com")}
                 </body></html>"""
            
proc importContent(content_file : string) : Content =
  let imported_content = newStringStream(readFile(content_file))
  var is_frontmatter : bool = false
  var buffer : string = ""
  var property : string = ""
  var exported_content = Content(path: content_file)
  buffer = imported_content.readLine()
  if buffer == "---": is_frontmatter = true
  while is_frontmatter:
    buffer = imported_content.readLine()
    if buffer == "---": is_frontmatter = false
    else:
      property = buffer.split(':')[0].strip()
      case property
      of "title": 
        exported_content.title = buffer.split(':')[1].strip()
      of "description":
        exported_content.description = buffer.split(':')[1].strip()
      of "date":
        exported_content.date = buffer.split(':')[1].strip().parseInt()
      else:
        discard
  exported_content.body = markdown(imported_content.readAll())
  if exported_content.date == 0:
    exported_content.web_path = fmt"/{content_file.split('/')[1].split('.')[0]}.html"
  else:
    exported_content.web_path = fmt"/{content_file.split('.')[0]}.html"
    let raw_post_date = parse($exported_content.date, "yyyyMMdd")
    exported_content.fdate = raw_post_date.format("d MMMM yyyy")
  echo fmt"TEST: {content_file}: {exported_content.web_path}"
  result = exported_content

proc main =
  setup()
  build()

when isMainModule:
  main()
