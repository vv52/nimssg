import times

type
  Category* = object
    term* : string
    scheme* : string
    label* : string

  ContentType* {.pure.} = enum
    Text = "text",
    Html = "html",
    Xhtml = "xhtml",
    Xml = "xml",
    HtmlXml = "html+xml"

  RelType* {.pure.} = enum
    Alternate = "alternate",
    Enclosure = "enclosure",
    Related = "related",
    Self = "self",
    Via = "via",

  Content* = object
    contentType* : ContentType
    src* : string
    content* : string

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

  Text* = object
    contentType* : ContentType
    content* : string

  Entry* = object
    id* : string
    title* : string
    updated* : DateTime
    author* : seq[Person]
    content* : Content
    link* : Link
    summary* : string
    category* : Category
    contributor* : seq[Person]
    published* : DateTime
    rights* : string
    source* : string
  
  AtomFeed* = object
    id* : string
    title* : string
    updated* : DateTime
    author* : seq[Person]
    link* : Link
    category* : Category
    contributor* : seq[Person]
    icon* : string
    logo* : string
    rights* : string
    subtitle* : string
