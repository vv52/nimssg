import os, parseopt, times, streams
import strformat, strutils

proc main() : void =
  try:
    let filename = paramStr(1)
    let post = newStringStream(readFile(filename))
    var outfile = newStringStream()
    var buffer : string = post.peekLine()
    if buffer != "---":
      echo "Error! Frontmatter not found"
      return
    else:
      outfile.writeLine(post.readLine())
    var done = false
    while not done:
      buffer = post.peekLine
      if buffer.contains("date"):
        outfile.writeLine(fmt"date: {now()}")
        discard post.readLine()
        outfile.write(post.readAll())
        done = true
      elif buffer == "---":
        echo """Error! "date" field not found in frontmatter"""
        return
      else:
        outfile.writeLine(post.readLine())
    outfile.setPosition(0)
    echo "Stamping file with current DateTime..."
    writeFile(filename, outfile.readAll())
    echo fmt"{filename} stamped successfully"
  except:
    echo "Error: I/O error"
  
when isMainModule:
  main()
