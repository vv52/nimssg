import std/streams

var tmpl = newStringStream(readFile("index.tmpl"))
var outp = newStringStream()
var content : bool = false
var buffer: string

while not tmpl.atEnd():
  tmpl.peekStr(2, buffer)
  if not content:
    if buffer == "<%":
      content = true
    else:
      try: outp.write($tmpl.readStr(1))
      except: break
  else:
    if buffer == "%>":
      content = false
      try: discard tmpl.readStr(2)
      except:
        break
    else:
      try: discard tmpl.readStr(1)
      except: break
outp.setPosition(0)
echo outp.readAll()
tmpl.close()
outp.close()
