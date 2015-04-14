# Changelog

# 0.2.6
- patch in a completion fix for https://github.com/codemirror/CodeMirror/issues/3189

# 0.2.5
- expose the hints panel `select`, `pick`, and `update` events

# 0.2.4
- expose the hints panel `shown` and `close` events (`HintResults.registerOnShown`)

# 0.2.3
- patch in a fix for the code completion popup

# 0.2.2
- upgrade to CodeMirror 5.1.0
- expose more functionality from the hint addon

# 0.2.1
- exposed `execCommand`

# 0.2.0
- upgrade to CodeMirror 5.0.0
- exposed `CodeMirror.getInputField`

# 0.1.6
- upgrade to CodeMirror 4.12.0
- added `CodeMirror.findModeByFileName`
- expose more API (LineHandle, ...)

# 0.1.5
- expose the `hints` (code completion) addon

# 0.1.4
- include additional (optional) modes and addons

# 0.1.3
- expose additional CodeMirror addons (comment editing, tag closing, element
  insertion)
- expose additional CodeMirror APIs, esp. around Tokens and modes

# 0.1.2
- added a missing hinter
- removed all but a few modes from the defaults (codemirror.js went from 1.2MB to 520k)

# 0.1.1
- added the ability to create `TextMarker`s (see `Doc.markText` and associated methods)
- upgrade to CodeMirror 4.11.0

# 0.1.0
- upgrade to CodeMirror 4.9.0
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
- upgrade to CodeMirror 4.8.0
- expose `CodeMirror.findModeByExtension`, `CodeMirror.findModeByMime`,
  and `CodeMirror.findModeByName`

# 0.0.8
- upgrade to CodeMirror 4.7.0

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
- changed to consuming CodeMirror from bower
- we now concatenate all modes into the main codemirror.js file

# 0.0.1
- Using CodeMirror 4.4.0 (http://codemirror.net/doc/compress.html)
