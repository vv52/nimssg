import std/streams

var final = newFileStream("index.html")
var tmpl = newStringStream(readFile("index.tmpl"))
var outp = newStringStream()
var inst = newStringStream()
var content : bool = false
var buffer: string

while not tmpl.atEnd():
  tmpl.peekStr(2, buffer)
  if not content:
    if buffer == "<%":
      content = true
      try: discard tmpl.readStr(2)
      except: break
    else:
      try: outp.write($tmpl.readStr(1))
      except: break
  else:
    if buffer == "%>":
      content = false
      try:
        discard tmpl.readStr(2)
        inst.write("\n")
      except: break
    else:
      try: inst.write($tmpl.readStr(1))
      except: break
outp.setPosition(0)
inst.setPosition(0)
echo outp.readAll()
echo inst.readAll()
# final.write(outp.readAll())
tmpl.close()
outp.close()
final.close()
