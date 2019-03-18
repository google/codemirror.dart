# codemirror.dart

[![Build Status](https://travis-ci.org/google/codemirror.dart.svg?branch=master)](https://travis-ci.org/google/codemirror.dart)
[![Dart strong mode](https://img.shields.io/badge/dart-strong%20mode-blue.svg)](https://github.com/dart-lang/dev_compiler/blob/master/STRONG_MODE.md)

## What is it?

A Dart wrapper around the CodeMirror text editor. From 
[codemirror.net](http://codemirror.net/):

> CodeMirror is a versatile text editor implemented in JavaScript for the
browser. It is specialized for editing code, and comes with a number of language
modes and addons that implement more advanced editing functionality.

## An example

```dart
Map options = {
  'mode': 'javascript',
  'theme': 'monokai'
};

CodeMirror editor = CodeMirror.fromElement(
    querySelector('#textContainer'), options: options);
editor.getDoc().setValue('foo.bar(1, 2, 3);');
```

See also our
[example/](https://github.com/google/codemirror.dart/tree/master/example)
directory.

## How do I use it?

In your main html file, link to the style sheet:

    <link href="packages/codemirror/codemirror.css" rel="stylesheet">
    
reference the CodeMirror JavaScript code:

    <script src="packages/codemirror/codemirror.js"></script>

and, in your Dart code, import the library:

    import 'package:codemirror/codemirror.dart';

## What about modes? Addons?

This Dart package ships with several language modes built in. CodeMirror itself
supports over 100 modes; the modes built into the Dart package include the
usual suspects for web development - `css`, `html`, `dart` and `javascript` as
well as a few
[others](https://github.com/google/codemirror.dart/blob/master/tool/grind.dart#L122).
In order to add additional modes, you'll need to reference the mode file from
your html entry-point. So,

    <script src="packages/codemirror/mode/lua.js"></script>

will bring in support for Lua.

Similarly with addons, we've included a few common ones, and have made the
others available to import on a case-by-case basis. In order to use the
`active-line` addon, import:

    <script src="packages/codemirror/addon/selection/active-line.js"></script>

Be aware that many addons need additional configuration in order to enable then.
This is generally done by passing values into the options of the CodeMirror
constructor.

Some addons are exposed through the main Dart interface. Some are exposed via
side-car Dart libraries available in the main
[package](https://github.com/google/codemirror.dart/tree/master/lib), and some
have yet to be exposed. Pull requests welcome :)

## Themes

By importing the codemirror.css file:

    <link href="packages/codemirror/codemirror.css" rel="stylesheet">

You get access to all the CodeMirror themes. If you only want a few, or don't
want to pay the network roundtrip cost to load all the themes, you can import
only the ones you're interested in:

    <link href="packages/codemirror/theme/monokai.css" rel="stylesheet">
    <link href="packages/codemirror/theme/zenburn.css" rel="stylesheet">

## Polymer transformer

The Polymer transfomer will inline our theme css references incorrectly.
Currently, to use the `codemirror` package with Polymer, you'll need to add the
following lines to your `pubspec.yaml` file.

```yaml
- polymer:
    entry_points: web/foo_bar.html
    inline_stylesheets:
      packages/codemirror/codemirror.css: false
```          

## Disclaimer

This is not an official Google product.
