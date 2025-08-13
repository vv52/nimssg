import times, streams, strformat

type
  # this isn't used yet
  Category* = object
    term* : string
    scheme* : string
    label* : string

  # this isn't used yet
  ContentType* {.pure.} = enum
    Text = "text",
    Html = "html",
    Xhtml = "xhtml",
    Xml = "xml",
    HtmlXml = "html+xml"

  # this isn't used yet
  RelType* {.pure.} = enum
    Alternate = "alternate",
    Enclosure = "enclosure",
    Related = "related",
    Self = "self",
    Via = "via",

  # this isn't used yet
  Content* = object
    contentType* : ContentType
    src* : string
    content* : string

  # this isn't used yet
  Link* = object
    href* : string
    rel* : RelType = RelType.Alternate
    contentType* : ContentType
    hreflang* : string
    title* : string
    length* : int
  
  Person* = object
    name* : string
    uri* : string
    email* : string

  # this isn't used yet
  Text* = object
    contentType* : ContentType
    content* : string

  Entry* = object
    id* : string
    title* : string
    updated* : DateTime
    author* : seq[Person]
    content* : string
    link* : string
    summary* : string
    category* : string
    contributor* : seq[Person]
    published* : DateTime
    rights* : string
    source* : string
  
  AtomFeed* = object
    id* : string
    title* : string
    updated* : DateTime
    author* : seq[Person]
    link* : string
    category* : string
    contributor* : seq[Person]
    icon* : string
    logo* : string
    rights* : string
    subtitle* : string
    entries* : seq[Entry]

proc generateFeed*(feed: AtomFeed, filename: string = "atom.xml") : string =
  var outputXml = newStringStream()
  outputXml.writeLine("""<? version="1.0" encoding="utf-8"?>""")
  outputXml.writeLine("""<feed xmlns="http://www.w3.org/2005/Atom">""")
  #
  outputXml.writeLine(fmt"""<title>{feed.title}</title>""")
  outputXml.writeLine(fmt"""<link href="{feed.link}"/>""")
  outputXml.writeLine(fmt"""<updated>{$feed.updated}</updated>""")
  if feed.author.len != 0:
    outputXml.writeLine("""<author>""")
    for author in feed.author:
      outputXml.writeLine(fmt"""  <name>{author.name}</name>""")
    outputXml.writeLine("""</author>""")
  outputXml.writeLine(fmt"""<id>{feed.id}</id>""")
  if feed.entries.len != 0:
    for entry in feed.entries:
      outputXml.writeLine("""<entry>""")
      # TODO generate entries
      outputXml.writeLine("""</entry>""")
  outputXml.writeLine("""</feed>""")
  outputXml.setPosition(0)
  result = outputXml.readAll()
