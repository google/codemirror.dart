// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library example.simple;

import 'dart:html';

import 'package:codemirror/codemirror.dart';

void main() {
  Map options = { 'theme': 'zenburn' };
  String text = _sampleText;

  CodeMirror editor = new CodeMirror.fromElement(
      querySelector('#textContainer'), options: options);
  Doc doc = new Doc(text, 'dart');
  editor.swapDoc(doc);

  querySelector('#version').text = "CodeMirror version ${CodeMirror.version}";

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
    print('todo: handle find');
  });

  print(CodeMirror.MODES);
  print(CodeMirror.MIME_MODES);
  print(CodeMirror.COMMANDS);

  editor.onDoubleClick.listen((MouseEvent evt) {
    Doc doc = editor.getDoc();
    print('[${doc.getLine(doc.getCursor().line).trim()}]');
  });
}

void _updateFooter(CodeMirror editor) {
  Position pos = editor.getCursor();
  int off = editor.getDoc().indexFromPos(pos);
  String str = 'line ${pos.line} • column ${pos.ch} • offset ${off}'
      + (editor.getDoc().isClean() ? '' : ' • (modified)');
  querySelector('#footer').text = str;
}

final String _sampleText = r'''
import 'dart:math' show Random;

void main() {
  print(new Die(n: 12).roll());
}

// Define a class.
class Die {
  // Define a class variable.
  static Random shaker = new Random();

  // Define instance variables.
  int sides, value;

  // Define a method using shorthand syntax.
  String toString() => '$value';

  // Define a constructor.
  Die({int n: 6}) {
    if (4 <= n && n <= 20) {
      sides = n;
    } else {
      // Support for errors and exceptions.
      throw new ArgumentError(/* */);
    }
  }

  // Define an instance method.
  int roll() {
    return value = shaker.nextInt(sides) + 1;
  }
}
''';
