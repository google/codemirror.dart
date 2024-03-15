// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

@TestOn('browser')
library codemirror.tests;

import 'package:web/web.dart';

import 'package:codemirror/codemirror.dart';
import 'package:test/test.dart';

// TODO: test double click

// TODO: document mutation

final Element editorHost = HTMLDivElement();

void main() {
  document.body!.appendChild(editorHost);

  group('simple', createSimpleTests);
  group('CodeMirror', createCodeMirrorTests);
  group('CodeMirror (static) ', createCodeMirrorStaticTests);
  group('Doc', createDocTests);
  group('HtmlDoc', createHtmlDocTests);
  group('history', createHistoryTests);
}

void createSimpleTests() {
  test('create', () {
    var editor = CodeMirror.fromElement(editorHost);
    expect(editor, isNotNull);
    expect(editorHost.parentElement, isNotNull);
    editor.dispose();
    editorHost.innerHTML = '';
  });
}

void createCodeMirrorStaticTests() {
  test('modes', () {
    expect(CodeMirror.modes.length, greaterThanOrEqualTo(10));
  });

  test('mime modes', () {
    expect(CodeMirror.mimeModes.length, greaterThanOrEqualTo(10));
  });

  test('commands', () {
    expect(CodeMirror.commands.length, greaterThanOrEqualTo(10));
  });

  test('key map', () {
    expect(CodeMirror.keyMaps.length, 4);
  });

  test('themes', () {
    expect(CodeMirror.themes.length, greaterThanOrEqualTo(10));
  });

  test('version', () {
    expect(CodeMirror.version!.length, greaterThanOrEqualTo(3));
  });
}

void createCodeMirrorTests() {
  late CodeMirror editor;

  setUp(() {
    editor = CodeMirror.fromElement(editorHost);
  });

  tearDown(() {
    editor.dispose();
    editorHost.innerHTML = '';
  });

  test('simple', () {
    expect(editor, isNotNull);
    expect(editorHost.parentElement, isNotNull);
  });

  test('getOption / setOption', () {
    expect(editor.getOption('lineWrapping'), false);
    editor.setOption('lineWrapping', true);
    expect(editor.getOption('lineWrapping'), true);
  });

  test('getLine', () {
    var doc = editor.doc;
    doc.setValue('one\ntwo\nthree');
    expect(editor.getLine(0), 'one');
    expect(editor.getLine(1), 'two');
    expect(editor.getLine(2), 'three');
  });
}

void createDocTests() {
  late CodeMirror editor;

  setUp(() {
    editor = CodeMirror.fromElement(editorHost);
    editor.setMode('clike');
  });

  tearDown(() {
    editor.dispose();
    editorHost.innerHTML = '';
  });

  test('getValue / getValue', () {
    var doc = editor.doc;
    expect(doc.getValue(), '');
    doc.setValue('foo bar');
    expect(doc.getValue(), 'foo bar');
  });

  test('getLine', () {
    var doc = editor.doc;
    doc.setValue('one\ntwo\nthree');
    expect(doc.getLine(0), 'one');
    expect(doc.getLine(1), 'two');
    expect(doc.getLine(2), 'three');
  });

  test('getMode', () {
    var doc = editor.doc;
    expect(doc.getMode()['name'], 'clike');
    expect(doc.getModeName(), 'clike');
  });

  test('eachLine', () {
    var doc = editor.doc;
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
    var doc = editor.doc;
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
    var doc = editor.doc;
    doc.setValue('foo bar');

    doc.addSelection(anchor: Position(0, 0));
    doc.addSelection(anchor: Position(0, 4));
    doc.setExtending(true);
    doc.extendSelections([Position(0, 3), Position(0, 7)]);
    expect(doc.getSelections(), ['foo', 'bar']);
  });

  test('extendSelectionsBy', () {
    var doc = editor.doc;
    doc.setValue('foo bar');

    doc.addSelection(anchor: Position(0, 0));
    doc.addSelection(anchor: Position(0, 4));
    doc.setExtending(true);
    doc.extendSelectionsBy((Span range, int i) {
      return Position(range.head.line, range.head.ch! + 3);
    });
    expect(doc.getSelections(), ['foo', 'bar']);
  });
}

void createHtmlDocTests() {
  late CodeMirror editor;

  setUp(() {
    editor = CodeMirror.fromElement(editorHost, options: {'mode': 'text/html'});
  });

  tearDown(() {
    editor.dispose();
    editorHost.innerHTML = '';
  });

  test('getModeAt', () {
    var doc = editor.doc;
    doc.setValue('<style>\np {color: black;}\n</style>');
    var mode = doc.getModeAt(Position(2, 0));
    expect(mode['name'], 'css');
    expect(doc.getModeNameAt(Position(2, 0)), 'css');
  });
}

void createHistoryTests() {
  late CodeMirror editor;

  setUp(() {
    editor = CodeMirror.fromElement(editorHost);
  });

  tearDown(() {
    editor.dispose();
    editorHost.innerHTML = '';
  });

  test('undo / redo', () {
    var doc = editor.doc;
    _expectHistory(doc, 0, 0);
    doc.replaceRange('foo', doc.getCursor());
    _expectHistory(doc, 1, 0);
    doc.undo();
    _expectHistory(doc, 0, 1);
    doc.redo();
    _expectHistory(doc, 1, 0);
  });

  test('clearHistory', () {
    var doc = editor.doc;
    doc.replaceRange('foo', doc.getCursor());
    _expectHistory(doc, 1, 0);
    doc.clearHistory();
    _expectHistory(doc, 0, 0);
  });

  test('getHistory', () {
    var doc = editor.doc;
    doc.setValue('one\ntwo\nthree');
    expect(doc.getHistory(), isNotNull);
  });
}

void _expectHistory(Doc doc, int undo, int redo) {
  Map m = doc.historySize();
  expect(m['undo'], undo);
  expect(m['redo'], redo);
}
