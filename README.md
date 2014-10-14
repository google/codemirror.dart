# codemirror.dart

[![Build Status](https://travis-ci.org/google/codemirror.dart.svg?branch=master)](https://travis-ci.org/google/codemirror.dart)

## What is it?

A Dart wrapper around the CodeMirror text editor. From 
[codemirror.net](http://codemirror.net/):

> CodeMirror is a versatile text editor implemented in JavaScript for the
browser. It is specialized for editing code, and comes with a number of language
modes and addons that implement more advanced editing functionality.

## An example

```
Map options = {
  'mode':  'javascript',
  'theme': 'monokai'
};

CodeMirror editor = new CodeMirror.fromElement(
    querySelector('#textContainer'), options: options);
editor.setValue('foo.bar(1, 2, 3);');
```

## How do I use it?

In your main html file, link to the style sheet:

    <link href="packages/codemirror/codemirror.css" rel="stylesheet">
    
reference the CodeMirror JavaScript code:

    <script src="packages/codemirror/lib/codemirror.js"></script>

and, in your Dart code, import the library:

    import 'package:codemirror/codemirror.dart';
