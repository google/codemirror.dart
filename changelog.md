# Changelog

# TODO:
- upgrade to codemirror 4.11.0

# 0.1.0
- upgrade to codemirror 4.9.0
- a Dart mode is now available (http://codemirror.net/mode/dart/index.html)
- rev'd to the first stable release version

# 0.0.13
- added `posFromIndex` and `indexFromPos`

# 0.0.12
- added a `CodeMirror.fromJsObject` constructor
- added `CodeMirror.getLine`

# 0.0.11
- expose some gutter, widget, and marker manipulation methods
- some support for the lint addon

# 0.0.10
- included the addon/ directory in the package
- concatenated likely addons to the codemirror.js script

# 0.0.9
- upgrade to codemirror 4.8.0
- expose `CodeMirror.findModeByExtension`, `CodeMirror.findModeByMime`,
  and `CodeMirror.findModeByName`

# 0.0.8
- upgrade to codemirror 4.7.0

# 0.0.7
- fixed a bug in `Doc.onChange`
- fixed a bug in `CodeMirror.getReadOnly`
- added `Doc.getSelection`

# 0.0.6
- added a new constructor for `Doc`

# 0.0.5
- add a `CodeMirror.swapDoc` method

# 0.0.4
- fix for exception when listening for changes

# 0.0.3
- republished to capture files omitted due to the .gitignore pub behavior

# 0.0.2
- changed to consuming codemirror from bower
- we now concatenate all modes into the main codemirror.js file

# 0.0.1
- Using codemirror 4.4.0 (http://codemirror.net/doc/compress.html)
