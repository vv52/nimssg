# nimssg
super simple static site generator

### dependencies
````
nimble install markdown
nimble install dekao
nimble install htmlunescape
````

### build
```
nim c -d:release ssg.nim
```

### usage
- place *.md blog posts in drafts/
- place *.md pages in pages/
- place custom.css in root if used (simplecss ext)
- place favicon.ico in root
- run ssg to stamp drafts with datetime and then generate site files into public_html/

if drafts/, posts/, or pages/ do not exist, they will be created on run

implements a simplified frontmatter
supported metadata:
- title (required)
- description (required)
- author (optional, provided by atom.ini if blank)
- date (will be overwritten by datetime stamp if in drafts/, can be manually entered as unix timestamp if file placed directly into posts/)

atom.ini also required
```
id=https://badslime.xyz
title=badslime blog
author=vv52
link=https://badslime.xyz
```
