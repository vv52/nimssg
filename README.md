# nimssg
super simple static site generator

### dependencies
````
nimble install markdown
nimble install dekao
````

### build
```
nim c -r ssg.nim
```

### usage
- place *.md blog posts in posts/
- place *.md pages in pages/
- place custom.css in root if used (simplecss ext)
- run ssg to generate site files into .dist/

if posts/ or pages/ do not exist, they will be created on run

implements a simplified frontmatter
supported metadata:
- title (required)
- date ("yyyyMMdd"; required for posts)
- description (optional)
