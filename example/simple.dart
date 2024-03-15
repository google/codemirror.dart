// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library example.simple;

import 'package:web/web.dart';

import 'package:codemirror/codemirror.dart';
import 'package:codemirror/hints.dart';

void main() {
  var options = {
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

  var editor = CodeMirror.fromTextArea(
      document.querySelector('#textContainer') as HTMLTextAreaElement?,
      options: options);

  document.querySelector('#version')!.text =
      'CodeMirror version ${CodeMirror.version}';

  Hints.registerHintsHelper('dart', _dartCompleter);
  Hints.registerHintsHelperAsync('dart', _dartCompleterAsync);

  // Theme control.
  final themeSelect = document.querySelector('#theme') as HTMLSelectElement;
  for (final theme in CodeMirror.themes) {
    themeSelect.add(HTMLOptionElement()
      ..value = theme
      ..text = theme);
    if (theme == editor.getTheme()) {
      themeSelect.selectedIndex = themeSelect.length - 1;
    }
  }
  themeSelect.onChange.listen((e) {
    var themeName = (themeSelect.options.item(themeSelect.selectedIndex)
            as HTMLOptionElement)
        .value;
    editor.setTheme(themeName);
  });

  // Mode control.
  final modeSelect = document.querySelector('#mode') as HTMLSelectElement;
  for (final mode in CodeMirror.modes) {
    modeSelect.add(HTMLOptionElement()
      ..value = mode
      ..text = mode);
    if (mode == editor.getMode()) {
      modeSelect.selectedIndex = modeSelect.length! - 1;
    }
  }
  modeSelect.onChange.listen((e) {
    var modeName = (modeSelect.options.item(themeSelect.selectedIndex)
            as HTMLOptionElement)
        .value;
    editor.setMode(modeName);
  });

  // Show line numbers.
  final lineNumbers =
      document.querySelector('#lineNumbers') as HTMLInputElement;
  lineNumbers.onChange.listen((e) {
    editor.setLineNumbers(lineNumbers.checked);
  });

  // Indent with tabs.
  final tabIndent = document.querySelector('#tabIndent') as HTMLInputElement;
  tabIndent.onChange.listen((e) {
    editor.setIndentWithTabs(tabIndent.checked);
  });

  // Status line.
  _updateFooter(editor);
  editor.onCursorActivity.listen((_) => _updateFooter(editor));

  editor.refresh();
  editor.focus();

  CodeMirror.addCommand('find', (foo) {
    /*LineHandle handle =*/ editor.doc.getLineHandle(editor.getCursor().line);

    print('todo: handle find');
  });

  print(CodeMirror.modes);
  print(CodeMirror.mimeModes);
  print(CodeMirror.commands);

  editor.onDoubleClick.listen((MouseEvent evt) {
    var doc = editor.doc;
    print('[${doc.getLine(doc.getCursor().line)!.trim()}]');
  });

//  Element e = new ParagraphElement();
//  e.text = 'Lorem Ipsum.';
//  PanelContainer container = Panel.addPanel(editor, e, below: true);
//  e.onClick.listen((_) => container.clear());
}

void _updateFooter(CodeMirror editor) {
  var pos = editor.getCursor();
  var off = editor.doc.indexFromPos(pos);
  var str =
      'line ${pos.line} • column ${pos.ch} • offset $off${editor.doc.isClean() ? '' : ' • (modified)'}';
  document.querySelector('#footer')!.text = str;
}

HintResults _dartCompleter(CodeMirror editor, [HintsOptions? options]) {
  var cur = editor.getCursor();
  var word = _getCurrentWord(editor).toLowerCase();
  var list = _numbers
      .where((s) => s.startsWith(word))
      .map((s) => HintResult(s))
      .toList();

  var results = HintResults.fromHints(list,
      Position(cur.line, cur.ch! - word.length), Position(cur.line, cur.ch));
  results.registerOnShown(() => print('hints shown'));
  results.registerOnSelect((completion, element) {
    print(['hints select: $completion']);
  });
  results.registerOnPick((completion) {
    print(['hints pick: $completion']);
  });
  results.registerOnUpdate(() => print('hints update'));
  results.registerOnClose(() => print('hints close'));

  return results;
}

//void _hintRenderer(Element element, HintResult hint) {
//  element.children.add(new DivElement()..text = hint.text);
//}

//void _hintApplier(CodeMirror editor, HintResult hint, Position from, Position to) {
//  editor.getDoc().replaceRange(hint.text + "_foo_", from, to);
//}

Future<HintResults> _dartCompleterAsync(CodeMirror editor,
    [HintsOptions? options]) {
  var cur = editor.getCursor();
  var word = _getCurrentWord(editor).toLowerCase();
  var list = List.of(_numbers.where((s) => s.startsWith(word)));

  return Future.delayed(Duration(milliseconds: 200), () {
    return HintResults.fromStrings(list,
        Position(cur.line, cur.ch! - word.length), Position(cur.line, cur.ch));
  });
}

const List<String> _numbers = [
  'zero',
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine'
];

final RegExp _ids = RegExp(r'[a-zA-Z_0-9]');

String _getCurrentWord(CodeMirror editor) {
  var cur = editor.getCursor();
  var line = editor.getLine(cur.line);
  var buf = StringBuffer();

  for (var i = cur.ch! - 1; i >= 0; i--) {
    var c = line![i];
    if (_ids.hasMatch(c)) {
      buf.write(c);
    } else {
      break;
    }
  }

  return String.fromCharCodes(buf.toString().codeUnits.reversed);
}
