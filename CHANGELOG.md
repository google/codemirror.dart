# Changelog

## 0.7.3+5.65.2
- `build` task now creates all required output directories before proceeding with build.
- Added `build_minified` task which minifies all codemirror source files using the google closure compilers SIMPLE_OPTIMIZATIONS before running `build` task.  The final minified output is functionaly equivalent to the non-minified version, only smaller.  Node is required for `build_minified` as npm is used to install the google closure compiler, et al.
- Added `clean_node` and `clean_minified` tasks to remove all artifacts from the `build_minified` task
- Renamed `clean` to `clean_lib` and fixed it so that it truely removed all artifacts from the `build` task
- Made `clean` dependent on `clean_lib`, `clean_node` and `clean_minified` so that the clean task will run all these in turn and clean all possible artifacts from either the `build` or `build_minified` tasks
- By default now create a `css/codemirror.css` file which has all of the codemirror css files dart-pad uses contenated together.  `--noextras` option can be used to create same codemirror.css as previous version (preventing contenation)
- By default output `codemirror.js` file now includes all additional codemirror addon files which dart-pad now uses. `--noextras` option can be used to create the same codemirror.js file as previous version  
- By default `codemirror.js` and `css/codemirror.css` output files both receive a summary header comment which details all concontenated codemirror source files they include.  `--noheader` option can be used to prevent the summary header and produce the same output as previous version

## 0.7.2+5.65.2
- Update to CodeMirror 5.65.2

## 0.7.1+5.65.1
- Update to CodeMirror 5.65.1

## 0.7.0+5.65.0
- 0.6.8 contained API breaking changes, should have been a semver step release

## 0.6.8+5.65.0
- Update to CodeMirror 5.65.0
- Deprecate and replace various APIs to match Dart standards
- Switch some nullable types to non-nullable

## 0.6.7+5.63.3
 - Update to CodeMirror 5.63.3

## 0.6.6+5.63.1
 - Update to CodeMirror 5.63.1

## 0.6.5+5.62.3
 - Update to CodeMirror 5.62.3
 - Migrate from `pedantic` to `lints/recomended`

## 0.6.4+5.62.2
 - Update to CodeMirror 5.62.2
 - Add SearchCursor wrapper (thanks to @ayshiff) 

## 0.6.3+5.62.0
 - Update to CodeMirror 5.62.0

## 0.6.2+5.61.1
 - Update to CodeMirror 5.61.1

## 0.6.1+5.61.0
 - Update to CodeMirror 5.61.0

## 0.6.0+5.60.0
 - Same as 0.6.0-nullsafety.0+5.60.0

## 0.6.0-nullsafety.0+5.60.0
 - Null safety migration
 - Update to CodeMirror 5.60.0

## 0.5.24+5.59.2
 - Update to CodeMirror 5.59.2

## 0.5.23+5.59.1
 - Update to CodeMirror 5.59.1

## 0.5.22+5.59.0
 - Update to CodeMirror 5.59.0

## 0.5.21+5.58.0
 - Update to CodeMirror 5.58.0

## 0.5.20+5.57.0
 - Update to CodeMirror 5.57.0

## 0.5.19+5.56.0
 - Update to CodeMirror 5.56.0

## 0.5.18+5.55.0
 - Update to CodeMirror 5.55.0

## 0.5.17+5.54.0
 - Update to CodeMirror 5.54.0

## 0.5.16+5.53.0
 - Update to CodeMirror 5.53.0

## 0.5.15+5.52.2
 - Update to CodeMirror 5.52.2

## 0.5.14+5.52.0
 - Update to CodeMirror 5.52.0

## 0.5.13+5.50.2
- Update to CodeMirror 5.50.2
- Add a `className` option to `addLineWidget`
- New themes: [ayu-dark](https://codemirror.net/demo/theme.html#ayu-dark) and
 [ayu-mirage](https://codemirror.net/demo/theme.html#ayu-mirage)


## 0.5.12+5.49.2
- Update to CodeMirror 5.49.2

## 0.5.11+5.49.0
- update to CodeMirror 5.49.0
- refresh exposed list of themes

## 0.5.10
- fix bug in TextMarker.find() method introduced by Dart 2.0.

## 0.5.9
- update to CodeMirror 5.48.4

## 0.5.9-alpha
- update to CodeMirror 5.48.2+1 (pre-release)

## 0.5.8
- update to CodeMirror 5.48.2

## 0.5.7
- update to CodeMirror 5.48.0

## 0.5.6
- update to CodeMirror 5.47.0

## 0.5.5
- update to CodeMirror 5.46.0

## 0.5.4
- update to CodeMirror 5.45.0
- add `yonce` theme

## 0.5.3
- adjust the field types for the `ScrollInfo` class

## 0.5.2
- Replacing broken version (0.5.1+5.44.0) with a fixed version

## 0.5.1
 - update to CodeMirror 5.44.0
 - expose the `nord` theme

## 0.5.0
- update to CodeMirror 5.43.0
- fix a bug with `onGutterClick` when compiled with dart2js
- use the `package:pedantic` analysis options rule set

## 0.4.7
- expose `getScrollInfo`, `scrollIntoView`, `onGutterClick`

## 0.4.6
- fix a bug in removeLineClass

## 0.4.5
- fix v0.4.4 - update the Javascript codemirror resources

## 0.4.4
 - updated to CodeMirror 5.41.0
 - exposed more themes

## 0.4.3
- increase the SDK dependency range

## 0.4.2
- strong mode fixes
- remove the use of deprecated constants

## 0.4.1
- updated to CodeMirror 5.13.4
- expose `Doc.eachLine`
- expose `Doc.addSelection`
- expose `Doc.extendSelection`
- expose `Doc.extendSelections`
- expose `Doc.extendSelectionsBy`
- expose `Doc.setExtending` and `Doc.getExtending`

## 0.4.0
- update the `CodeMirror.addCommand` to better support custom commands

## 0.3.2
- updated to CodeMirror 5.8.0 (with improvements to the Dart mode)
- Dart mode: improved syntax highlighting for triple-quoted strings
- Dart mode: added syntax highlighting support for string interpolation

## 0.3.1
- strong mode fixes
- fix an issue with the async code completer

## 0.3.0
- updated to CodeMirror 5.7.0
- more strong mode fixes

## 0.2.9
- made ddc (strong mode) compliant
- fixed an issues returning the TextMarker positions of bookmarks

## 0.2.8
- updated to CodeMirror 5.5.0
- expose `defineExtension` and `defineDocExtension`

## 0.2.7
- updated to CodeMirror 5.2.0
- bug fix to `Doc.getModeAt`
- added `Doc.getModeName()` and `Doc.getModeNameAt()` methods

## 0.2.6
- patch in a completion fix for https://github.com/codemirror/CodeMirror/issues/3189

## 0.2.5
- expose the hints panel `select`, `pick`, and `update` events

## 0.2.4
- expose the hints panel `shown` and `close` events (`HintResults.registerOnShown`)

## 0.2.3
- patch in a fix for the code completion popup

## 0.2.2
- upgrade to CodeMirror 5.1.0
- expose more functionality from the hint addon

## 0.2.1
- exposed `execCommand`

## 0.2.0
- upgrade to CodeMirror 5.0.0
- exposed `CodeMirror.getInputField`

## 0.1.6
- upgrade to CodeMirror 4.12.0
- added `CodeMirror.findModeByFileName`
- expose more API (LineHandle, ...)

## 0.1.5
- expose the `hints` (code completion) addon

## 0.1.4
- include additional (optional) modes and addons

## 0.1.3
- expose additional CodeMirror addons (comment editing, tag closing, element
  insertion)
- expose additional CodeMirror APIs, esp. around Tokens and modes

## 0.1.2
- added a missing hinter
- removed all but a few modes from the defaults (codemirror.js went from 1.2MB to 520k)

## 0.1.1
- added the ability to create `TextMarker`s (see `Doc.markText` and associated methods)
- upgrade to CodeMirror 4.11.0

## 0.1.0
- upgrade to CodeMirror 4.9.0
- a Dart mode is now available (http://codemirror.net/mode/dart/index.html)
- rev'd to the first stable release version

## 0.0.13
- added `posFromIndex` and `indexFromPos`

## 0.0.12
- added a `CodeMirror.fromJsObject` constructor
- added `CodeMirror.getLine`

## 0.0.11
- expose some gutter, widget, and marker manipulation methods
- some support for the lint addon

## 0.0.10
- included the addon/ directory in the package
- concatenated likely addons to the codemirror.js script

## 0.0.9
- upgrade to CodeMirror 4.8.0
- expose `CodeMirror.findModeByExtension`, `CodeMirror.findModeByMime`,
  and `CodeMirror.findModeByName`

## 0.0.8
- upgrade to CodeMirror 4.7.0

## 0.0.7
- fixed a bug in `Doc.onChange`
- fixed a bug in `CodeMirror.getReadOnly`
- added `Doc.getSelection`

## 0.0.6
- added a new constructor for `Doc`

## 0.0.5
- add a `CodeMirror.swapDoc` method

## 0.0.4
- fix for exception when listening for changes

## 0.0.3
- republished to capture files omitted due to the .gitignore pub behavior

## 0.0.2
- changed to consuming CodeMirror from bower
- we now concatenate all modes into the main codemirror.js file

## 0.0.1
- Using CodeMirror 4.4.0 (http://codemirror.net/doc/compress.html)
