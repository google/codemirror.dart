// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

@TestOn('browser')
library codemirror.tests;

import 'dart:html';

import 'package:codemirror/codemirror.dart';
import 'package:test/test.dart';

// TODO: test double click

// TODO: document mutation

final Element editorHost = DivElement();

void main() {
  document.body.children.add(editorHost);

  group('simple', createSimpleTests);
  group('CodeMirror', createCodeMirrorTests);
  group('CodeMirror (static) ', createCodeMirrorStaticTests);
  group('Doc', createDocTests);
  group('HtmlDoc', createHtmlDocTests);
  group('history', createHistoryTests);
  group('MergeView', createMergeViewTests);
}

void createSimpleTests() {
  test('create', () {
    var editor = CodeMirror.fromElement(editorHost);
    expect(editor, isNotNull);
    expect(editorHost.parent, isNotNull);
    editor.dispose();
    editorHost.children.clear();
  });
}

void createCodeMirrorStaticTests() {
  test('modes', () {
    expect(CodeMirror.MODES.length, greaterThanOrEqualTo(10));
  });

  test('mime modes', () {
    expect(CodeMirror.MIME_MODES.length, greaterThanOrEqualTo(10));
  });

  test('commands', () {
    expect(CodeMirror.COMMANDS.length, greaterThanOrEqualTo(10));
  });

  test('key map', () {
    expect(CodeMirror.KEY_MAPS.length, 4);
  });

  test('themes', () {
    expect(CodeMirror.THEMES.length, greaterThanOrEqualTo(10));
  });

  test('version', () {
    expect(CodeMirror.version.length, greaterThanOrEqualTo(3));
  });
}

void createCodeMirrorTests() {
  CodeMirror editor;

  setUp(() {
    editor = CodeMirror.fromElement(editorHost);
  });

  tearDown(() {
    editor.dispose();
    editorHost.children.clear();
  });

  test('simple', () {
    expect(editor, isNotNull);
    expect(editorHost.parent, isNotNull);
  });

  test('getOption / setOption', () {
    expect(editor.getOption('lineWrapping'), false);
    editor.setOption('lineWrapping', true);
    expect(editor.getOption('lineWrapping'), true);
  });

  test('getLine', () {
    var doc = editor.getDoc();
    doc.setValue('one\ntwo\nthree');
    expect(editor.getLine(0), 'one');
    expect(editor.getLine(1), 'two');
    expect(editor.getLine(2), 'three');
  });
}

void createDocTests() {
  CodeMirror editor;

  setUp(() {
    editor = CodeMirror.fromElement(editorHost);
    editor.setMode('clike');
  });

  tearDown(() {
    editor.dispose();
    editorHost.children.clear();
  });

  test('getValue / getValue', () {
    var doc = editor.getDoc();
    expect(doc.getValue(), '');
    doc.setValue('foo bar');
    expect(doc.getValue(), 'foo bar');
  });

  test('getLine', () {
    var doc = editor.getDoc();
    doc.setValue('one\ntwo\nthree');
    expect(doc.getLine(0), 'one');
    expect(doc.getLine(1), 'two');
    expect(doc.getLine(2), 'three');
  });

  test('getMode', () {
    var doc = editor.getDoc();
    expect(doc.getMode()['name'], 'clike');
    expect(doc.getModeName(), 'clike');
  });

  test('eachLine', () {
    var doc = editor.getDoc();
    doc.setValue('one\ntwo\nthree');
    var lines = [];
    doc.eachLine((LineHandle line) {
      lines.add(line.text);
    });
    expect(lines.length, 3);
    expect(lines[0], 'one');
    expect(lines[1], 'two');
    expect(lines[2], 'three');
  });

  test('extendSelection', () {
    var doc = editor.getDoc();
    doc.setValue('foo bar');

    // Extending flag is off.
    doc.setSelection(Position(0, 0));
    doc.setExtending(false);
    doc.extendSelection(Position(0, 3));
    expect(doc.getSelection(), '');

    // Extending flag is on.
    doc.setSelection(Position(0, 0));
    doc.setExtending(true);
    doc.extendSelection(Position(0, 3));
    expect(doc.getSelection(), 'foo');
  });

  test('extendSelections', () {
    var doc = editor.getDoc();
    doc.setValue('foo bar');

    doc.addSelection(anchor: Position(0, 0));
    doc.addSelection(anchor: Position(0, 4));
    doc.setExtending(true);
    doc.extendSelections([Position(0, 3), Position(0, 7)]);
    expect(doc.getSelections(), ['foo', 'bar']);
  });

  test('extendSelectionsBy', () {
    var doc = editor.getDoc();
    doc.setValue('foo bar');

    doc.addSelection(anchor: Position(0, 0));
    doc.addSelection(anchor: Position(0, 4));
    doc.setExtending(true);
    doc.extendSelectionsBy((Span range, int i) {
      return Position(range.head.line, range.head.ch + 3);
    });
    expect(doc.getSelections(), ['foo', 'bar']);
  });
}

void createHtmlDocTests() {
  CodeMirror editor;

  setUp(() {
    editor = CodeMirror.fromElement(editorHost, options: {'mode': 'text/html'});
  });

  tearDown(() {
    editor.dispose();
    editorHost.children.clear();
  });

  test('getModeAt', () {
    var doc = editor.getDoc();
    doc.setValue('<style>\np {color: black;}\n</style>');
    var mode = doc.getModeAt(Position(2, 0));
    expect(mode['name'], 'css');
    expect(doc.getModeNameAt(Position(2, 0)), 'css');
  });
}

void createHistoryTests() {
  CodeMirror editor;

  setUp(() {
    editor = CodeMirror.fromElement(editorHost);
  });

  tearDown(() {
    editor.dispose();
    editorHost.children.clear();
  });

  test('undo / redo', () {
    var doc = editor.getDoc();
    _expectHistory(doc, 0, 0);
    doc.replaceRange('foo', doc.getCursor());
    _expectHistory(doc, 1, 0);
    doc.undo();
    _expectHistory(doc, 0, 1);
    doc.redo();
    _expectHistory(doc, 1, 0);
  });

  test('clearHistory', () {
    var doc = editor.getDoc();
    doc.replaceRange('foo', doc.getCursor());
    _expectHistory(doc, 1, 0);
    doc.clearHistory();
    _expectHistory(doc, 0, 0);
  });

  test('getHistory', () {
    var doc = editor.getDoc();
    doc.setValue('one\ntwo\nthree');
    expect(doc.getHistory(), isNotNull);
  });
}

void createMergeViewTests() {
  MergeView mergeView;

  const someMergeViewOptions = {
    'value': 'AAAAAA',
    'origLeft': 'BBBBBB',
    'showDifferences': true,
    'revertButtons': false,
  };

  mergeView = MergeView(editorHost, someMergeViewOptions);

  test('creates a MergeView class', () {
    expect(mergeView, isA<MergeView>());
  });

  test('has correct properties', () {
    expect(mergeView.edit, isA<CodeMirror>());
    expect(mergeView.left, isA<DiffView>());
  });

  group(DiffView, () {
    DiffView diffView;

    setUp(() {
      diffView = mergeView.left;
    });

    test('has correct properties', () {
      expect(diffView.edit, isA<CodeMirror>());
      expect(diffView.orig, isA<CodeMirror>());
    });

    test('has correct values', () {
      expect(diffView.edit.getDoc().getValue(), equals('AAAAAA'));
      expect(diffView.orig.getDoc().getValue(), equals('BBBBBB'));
    });
  });
}

void _expectHistory(Doc doc, int undo, int redo) {
  Map m = doc.historySize();
  expect(m['undo'], undo);
  expect(m['redo'], redo);
}
