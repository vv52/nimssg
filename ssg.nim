import std/os, std/times, std/streams
import std/strutils, std/strformat
import std/sequtils
import std/algorithm
import markdown, dekao
import atom, stamp

type
  Content = object
    path*: string
    web_path*: string
    title*: string
    description*: string
    date*: DateTime
    fdate*: string
    body*: string

proc setup() : void
proc build() : void
proc initDistDir() : void
proc stampDrafts() : void
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
  echo "Checking prerequisite directories..."
  if existsOrCreateDir("pages/"): echo "  Pages \u2713"
  else: echo "  Pages directory not found\n    Creating pages directory...\n    Pages \u2713"
  if existsOrCreateDir("posts/"): echo "  Posts \u2713"
  else: echo "  Posts directory not found\n    Creating posts directory...\n    Posts \u2713"
  if existsOrCreateDir("drafts/"): echo "  Drafts \u2713"
  else: echo "  Drafts directory not found\n    Creating drafts directory...\n    Drafts \u2713"

proc build() : void =
  initDistDir()
  echo "Stamping drafts..."
  stampDrafts()
  echo "Building site..."
  for page in getPages():
    writeFile(fmt"public_html/{page.web_path}", generatePage(page))
    echo fmt"  {page.web_path} " & "\u2713"
  writeFile("public_html/blog.html", generateBlog())
  echo "  /blog.html \u2713"
  if fileExists("custom.css"):
    copyFileToDir("custom.css", "public_html/")
    echo "  /custom.css \u2713"
  if fileExists("favicon.ico"):
    copyFileToDir("favicon.ico", "public_html/")
    echo "  /favicon.ico \u2713"
  # if fileExists("valid-atom.png"):
  #   copyFileToDir("valid-atom.png", "public_html/")
  if fileExists("feed-icon.png"):
    copyFileToDir("feed-icon.png", "public_html/")
  echo "Build complete"
  echo "Site files written to public_html directory"

proc initDistDir() : void =
  echo "Cleaning public_html directory..."
  removeDir("public_html/")
  createDir("public_html/")
  createDir("public_html/posts/")
  echo "  Directory initialized \u2713"

proc stampDrafts() : void =
  let drafts = toSeq(walkFiles("drafts/*.md"))
  for draft in drafts:
    stamp(draft)
  if drafts.len > 0:
    echo "  Drafts processed \u2713"
  else:
    echo "  No drafts found"

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
      link: rel "stylesheet"; href "/custom.css"
      link: rel "icon"; href "./favicon.ico"; ttype "image/x-icon"
      title: say content_title

proc generateHeader(page_content: Content) : string =
  result = render:
    header:
      # span ".right-edge":
      #   a: href "https://badslime.xyz/atom.xml"; img src "feed-icon.png"; alt "Atom feed"; title "Link to Atom feed"
      nav:
        a: href "/"; class "current"; say "Home"
        a: href "/blog"; say "Blog"
        # a: href "https://github.com/vv52"; say "GitHub"
        # a: href "https://gitlab.com/vexing-voyage"; say "GitLab"
        a: href "https://vexingvoyage.itch.io"; say "itch.io"
        # if fileExists("atom.ini"):
        #   link: rel "alternate"; title "Feed"; ttype "application/atom+xml"; href "/atom.xml"
          # a: href "/atom.xml"; say "Feed"
      h1: say page_content.title
      p: say page_content.description

proc generateBlogHeader(page_content: Content) : string =
  result = render:
    header:
      nav:
        a: href "/"; say "Home"
        a: href "/blog"; class "current"; say "Blog"
        # a: href "https://github.com/vv52"; say "GitHub"
        # a: href "https://gitlab.com/vexing-voyage"; say "GitLab"
        a: href "https://vexingvoyage.itch.io"; say "itch.io"
        # if fileExists("atom.ini"):
        #   link: rel "alternate"; title "Feed"; ttype "application/atom+xml"; href "/atom.xml"
        #   a: href "/atom.xml"; say "Feed"
      # echo page_content.path
      if page_content.path != "blog.html":
        try:
          p: i: say page_content.date.format("d MMMM yyyy")
        except:
          echo fmt"Error! No date stamp provided for post: {page_content.path}"
      p: say page_content.description

proc generateFooter(email_address: string) : string =
  result = render:
    footer:
      p:
        a: href fmt"mailto:{email_address}"; say email_address
      p:
        a: href "#top"; say "[Top]"
      # p:
        # a: href "https://badslime.xyz/atom.xml"; img src "feed-icon.png"; alt "Atom feed"; title "Link to Atom feed"
        # a: href "http://validator.w3.org/feed/check.cgi?url=https%3A//badslime.xyz/atom.xml"; img src "valid-atom.png"; alt "[Valid Atom 1.0]"; title "Validate my Atom 1.0 feed"
      p:
        a: href "https://badslime.xyz/atom.xml"; img src "feed-icon.png"; alt "Atom feed"; title "Link to Atom feed"
        # span ".left-edge":
        #   a: href "https://badslime.xyz/atom.xml"; img src "feed-icon.png"; alt "Atom feed"; title "Link to Atom feed"
        # span ".right-edge":
        #   a: href "http://validator.w3.org/feed/check.cgi?url=https%3A//badslime.xyz/atom.xml"; img src "valid-atom.png"; alt "[Valid Atom 1.0]"; title "Validate my Atom 1.0 feed"

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
  var feed = newAtomFeedFromFile()
  var trackedPosts : int = 5
  var posts = getPosts()
  posts.sort(contentCmp, order = SortOrder.Descending)
  var body_content = """"""
  for dated_post in posts:
    writeFile(fmt"public_html/{dated_post.web_path}", generatePost(dated_post))
    echo fmt"  {dated_post.web_path} " & "\u2713"
    body_content = body_content &
      fmt"""<article><h3><a href="{dated_post.web_path}">{dated_post.title}</a>
      <small><i>{$dated_post.fdate}</i></small></h3>"""
    if dated_post.description != "":
      body_content = body_content & fmt"""<hr />{dated_post.description}</article>"""
    else:
      body_content = body_content & """</article>"""
    if trackedPosts > 0:
      feed.entries.add(Entry(id: dated_post.web_path, title: dated_post.title, author: @[Person(name: feed.author[0].name)], content: dated_post.body, summary: dated_post.description, updated: dated_post.date))
      trackedPosts = trackedPosts - 1
  var blog : Content
  blog.title = "Blog"
  blog.description = "My blog"
  blog.path = "blog.html"
  if fileExists("atom.ini"):
    writeFile("public_html/atom.xml", generateFeed(feed))
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
        exported_content.date = parse(buffer[6 .. ^1], "yyyy-MM-dd'T'HH:mm:sszzz")
      else:
        discard
  exported_content.body = markdown(imported_content.readAll())
  if content_file.split('/')[0].strip() == "pages":
    exported_content.web_path = fmt"/{content_file.split('/')[1].split('.')[0]}.html"
  else:
    exported_content.web_path = fmt"/{content_file.split('.')[0]}.html"
    exported_content.fdate = exported_content.date.format("d MMMM yyyy")
  result = exported_content

proc main =
  setup()
  build()

when isMainModule:
  main()
