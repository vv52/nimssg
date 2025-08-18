import os, times, streams
import strformat, strutils

proc stamp*(filename : string) : void =
  try:
    let post = newStringStream(readFile(filename))
    var outfile = newStringStream()
    var buffer : string = post.peekLine()
    if buffer != "---":
      echo fmt"  Error! Frontmatter not found in {filename}"
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
        outfile.writeLine(fmt"date: {now()}")
        outfile.write(post.readAll())
        done = true
      else:
        outfile.writeLine(post.readLine())
    echo fmt"  Stamping {filename} with current DateTime..."
    outfile.setPosition(0)
    let outfile_path = fmt"""posts/{filename.split('/')[1]}"""
    writeFile(outfile_path, outfile.readAll())
    removeFile(filename)
    echo fmt"    {filename} stamped and moved to posts dir " & "\u2713"
  except:
    echo fmt"  Error: I/O error for {filename}"
 
