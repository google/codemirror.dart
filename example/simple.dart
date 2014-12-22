// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library example.simple;

import 'dart:html';

import 'package:codemirror/codemirror.dart';

void main() {
  Map options = { 'theme': "3024-day" };
  String text = """\n// You can edit this code! Click here and start typing.

package main

import "fmt"

func main() {
  fmt.Println("Hello, 世界")
}\n""";

  CodeMirror editor = new CodeMirror.fromElement(
      querySelector('#textContainer'), options: options);
  Doc doc = new Doc(text, 'go');
  editor.swapDoc(doc);

  // Theme control.
  SelectElement themeSelect = querySelector('#theme');
  for (String theme in CodeMirror.THEMES) {
    themeSelect.children.add(new OptionElement(value: theme)..text = theme);
  }
  themeSelect.onChange.listen((e) {
    String themeName = themeSelect.options[themeSelect.selectedIndex].value;
    editor.setTheme(themeName);
  });

  // Mode control.
  SelectElement modeSelect = querySelector('#mode');
  for (String mode in CodeMirror.MODES) {
    modeSelect.children.add(new OptionElement(value: mode)..text = mode);
    if (mode == 'go') {
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
  editor.onCursorActivity.listen((_) {
    Position pos = editor.getCursor();
    int off = editor.getDoc().indexFromPos(pos);
    writeFooter('line ${pos.line} column ${pos.ch} [offset ${off}]'
        + (editor.getDoc().isClean() ? '' : ' (dirty)'));
  });

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

void writeFooter(var obj) {
  querySelector('#footer').text = '${obj}';
}
