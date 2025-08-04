# nimssg
super simple static site generator

### dependencies
- nimble install markdown
- nimble install dekao

### build
```
nim c -r ssg.nim
```

### usage
place md blog posts in posts/
place md pages in pages/
place custom.css in root if used
run ssg to generate site files into .dist/

implements a simplified frontmatter
supported metadata:
- title (required)
- date (required for posts)
- description (optional)
