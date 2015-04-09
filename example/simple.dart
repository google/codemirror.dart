// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library example.simple;

import 'dart:html';

import 'package:codemirror/codemirror.dart';
import 'package:codemirror/hints.dart';

void main() {
  Map options = {
    'theme': 'zenburn',
    'continueComments': {'continueLineComment': false},
    'autoCloseTags': true,
    'mode': 'dart',
    'extraKeys': {
      'Ctrl-Space': 'autocomplete',
      'Cmd-/': 'toggleComment',
      'Ctrl-/': 'toggleComment'
    }
  };

  CodeMirror editor = new CodeMirror.fromTextArea(
      querySelector('#textContainer'), options: options);

  querySelector('#version').text = "CodeMirror version ${CodeMirror.version}";

  Hints.registerHintsHelper('dart', _dartCompleter);
  //Hints.registerHintsHelperAsync('dart', _dartCompleterAsync);

  // Theme control.
  SelectElement themeSelect = querySelector('#theme');
  for (String theme in CodeMirror.THEMES) {
    themeSelect.children.add(new OptionElement(value: theme)..text = theme);
    if (theme == editor.getTheme()) {
      themeSelect.selectedIndex = themeSelect.length - 1;
    }
  }
  themeSelect.onChange.listen((e) {
    String themeName = themeSelect.options[themeSelect.selectedIndex].value;
    editor.setTheme(themeName);
  });

  // Mode control.
  SelectElement modeSelect = querySelector('#mode');
  for (String mode in CodeMirror.MODES) {
    modeSelect.children.add(new OptionElement(value: mode)..text = mode);
    if (mode == editor.getMode()) {
      modeSelect.selectedIndex = modeSelect.length - 1;
    }
  }
  modeSelect.onChange.listen((e) {
    String modeName = modeSelect.options[modeSelect.selectedIndex].value;
    editor.setMode(modeName);
  });

  // Show line numbers.
  InputElement lineNumbers = querySelector('#lineNumbers');
  lineNumbers.onChange.listen((e) {
    editor.setLineNumbers(lineNumbers.checked);
  });

  // Indent with tabs.
  InputElement tabIndent = querySelector('#tabIndent');
  tabIndent.onChange.listen((e) {
    editor.setIndentWithTabs(tabIndent.checked);
  });

  // Status line.
  _updateFooter(editor);
  editor.onCursorActivity.listen((_) => _updateFooter(editor));

  editor.refresh();
  editor.focus();

  editor.addCommand('find', (foo) {
    /*LineHandle handle =*/ editor.getDoc().getLineHandle(editor.getCursor().line);

    print('todo: handle find');
  });

  print(CodeMirror.MODES);
  print(CodeMirror.MIME_MODES);
  print(CodeMirror.COMMANDS);

  editor.onDoubleClick.listen((MouseEvent evt) {
    Doc doc = editor.getDoc();
    print('[${doc.getLine(doc.getCursor().line).trim()}]');
  });

//  Element e = new ParagraphElement();
//  e.text = 'Lorem Ipsum.';
//  PanelContainer container = Panel.addPanel(editor, e, below: true);
//  e.onClick.listen((_) => container.clear());
}

void _updateFooter(CodeMirror editor) {
  Position pos = editor.getCursor();
  int off = editor.getDoc().indexFromPos(pos);
  String str = 'line ${pos.line} • column ${pos.ch} • offset ${off}'
      + (editor.getDoc().isClean() ? '' : ' • (modified)');
  querySelector('#footer').text = str;
}

HintResults _dartCompleter(CodeMirror editor, [HintsOptions options]) {
  Position cur = editor.getCursor();
  String word = _getCurrentWord(editor).toLowerCase();
  List<HintResult> list = _numbers
      .where((s) => s.startsWith(word))
      .map((s) => new HintResult(s))
      .toList();

  HintResults results = new HintResults.fromHints(
      list,
      new Position(cur.line, cur.ch - word.length),
      new Position(cur.line, cur.ch));
  results.registerOnShown(() => print('hints popup shown'));
  results.registerOnClose(() => print('hints popup hidden'));
  results.registerOnUpdate(() => print('hints popup update'));
  results.registerOnPick((completion) => print(['hints popup pick','${completion}']));
  results.registerOnSelect((completion,element) => print(['hint popup select','${completion}','${element}']));

  return results;
}

//void _hintRenderer(Element element, HintResult hint) {
//  element.children.add(new DivElement()..text = hint.text);
//}

//void _hintApplier(CodeMirror editor, HintResult hint, Position from, Position to) {
//  editor.getDoc().replaceRange(hint.text + "_foo_", from, to);
//}

//Future<HintResults> _dartCompleterAsync(CodeMirror editor,
//    [HintsOptions options]) {
//  Position cur = editor.getCursor();
//  String word = _getCurrentWord(editor).toLowerCase();
//  List<String> list = _numbers.where((s) => s.startsWith(word)).toList();
//
//  return new Future.delayed(new Duration(milliseconds: 200), () {
//    return new HintResults.fromStrings(
//        list,
//        new Position(cur.line, cur.ch - word.length),
//        new Position(cur.line, cur.ch));
//  });
//}

final List _numbers = [
  'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'
];

final RegExp _ids = new RegExp(r'[a-zA-Z_0-9]');

String _getCurrentWord(CodeMirror editor) {
  Position cur = editor.getCursor();
  String line = editor.getLine(cur.line);
  StringBuffer buf = new StringBuffer();

  for (int i = cur.ch - 1; i >= 0; i--) {
    String c = line[i];
    if (_ids.hasMatch(c)) {
      buf.write(c);
    } else {
      break;
    }
  }

  return new String.fromCharCodes(buf.toString().codeUnits.reversed);
}
