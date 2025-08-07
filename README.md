# nimssg
super simple static site generator

### dependencies
````
nimble install markdown
nimble install dekao
nimble install css_html_minify
````

### build
```
nim c -r ssg.nim
```

### usage
- place *.md blog posts in posts/
- place *.md pages in pages/
- place custom.css in root if used (simplecss ext)
- place favicon.ico in root
- run ssg to generate site files into .dist/

if posts/ or pages/ do not exist, they will be created on run

implements a simplified frontmatter
supported metadata:
- title (required)
- date ("yyyyMMdd"; required for posts)
- description (optional)
