// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library codemirror;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'src/js_utils.dart';

// TODO: code completion (hint/show-hint.js)

// TODO: displaying errors (see lint/lint.js addon)

// TODO: find, replace

/**
 * A parameter type into the [CodeMirror.addCommand] method.
 */
typedef void CommandHandler(CodeMirror editor);

/**
 * A wrapper around the CodeMirror editor.
 */
class CodeMirror extends ProxyHolder {
  static List<String> THEMES = [
    '3024-day',
    '3024-night',
    'ambiance-mobile',
    'ambiance',
    'base16-dark',
    'base16-light',
    'blackboard',
    'cobalt',
    'eclipse',
    'elegant',
    'erlang-dark',
    'lesser-dark',
    'mbo',
    'mdn-like',
    'midnight',
    'monokai',
    'neat',
    'neo',
    'night',
    'paraiso-dark',
    'paraiso-light',
    'pastel-on-dark',
    'rubyblue',
    'solarized',
    'the-matrix',
    'tomorrow-night-eighties',
    'twilight',
    'vibrant-ink',
    'xq-dark',
    'xq-light',
  ];

  static List<String> KEY_MAPS = [
    'default',
    'emacs',
    'sublime'
    'vim',
  ];

  static List<String> get MODES => keys(context['CodeMirror']['modes']);

  static List<String> get MIME_MODES => keys(context['CodeMirror']['mimeModes']);

  static List<String> get COMMANDS => keys(context['CodeMirror']['commands']);

  static JsObject _createFromElement(Element element, Map options) {
    if (options == null) {
      return new JsObject(context['CodeMirror'], [element]);
    } else {
      return new JsObject(context['CodeMirror'], [element, jsify(options)]);
    }
  }

  Doc _doc;

  /**
   * Create a new CodeMirror editor in the given element. See
   * http://codemirror.net/doc/manual.html#config for valid options values.
   */
  CodeMirror.fromElement(Element element, {Map options}) :
      super(_createFromElement(element, options));

  /**
   * Fires every time the content of the editor is changed.
   */
  Stream get onChange => onEvent('change', true);

  /**
   * Will be fired when the cursor or selection moves, or any change is made to
   * the editor content.
   */
  Stream get onCursorActivity => onEvent('cursorActivity');

  /**
   * Fired when a mouse is clicked. You can preventDefault the event to signal
   * that CodeMirror should do no further handling.
   */
  Stream<MouseEvent> get onMouseDown => onEvent('mousedown', true);

  /**
   * Fired when a mouse is double-clicked. You can preventDefault the event to
   * signal that CodeMirror should do no further handling.
   */
  Stream<MouseEvent> get onDoubleClick => onEvent('dblclick', true);

  //Stream<MouseEvent> get onContextMenu => onEvent('contextmenu', true);

  /**
   * Retrieve the currently active document from an editor.
   */
  Doc getDoc() {
    if (_doc == null) {
      _doc = new Doc.fromProxy(call('getDoc'));
    }
    return _doc;
  }

  /**
   * Attach a new document to the editor.
   */
  void swapDoc(Doc doc) {
    callArg('swapDoc', doc.jsProxy);
  }

  /**
   * Retrieves the current value of the given option for this editor instance.
   */
  dynamic getOption(String option) => callArg('getOption', option);

  /**
   * Change the configuration of the editor. option should the name of an
   * option, and value should be a valid value for that option.
   */
  void setOption(String option, var value) =>
      callArgs('setOption', [option, value]);

  String getTheme() => getOption('theme');

  void setTheme(String theme) => setOption('theme', theme);

  String getMode() => getOption('mode');

  void setMode(String mode) => setOption('mode', mode);

  /**
   * Return the current key map.
   */
  String getKeyMap() => getOption('keyMap');

  /**
   * Valid options are `default`, `vim`, `emacs`, and `sublime`.
   */
  void setKeyMap(String value) => setOption('keyMap', value);

  /**
   * Whether to show line numbers to the left of the editor.
   */
  bool getLineNumbers() => getOption('lineNumbers');

  /**
   * Whether to show line numbers to the left of the editor.
   */
  void setLineNumbers(bool value) => setOption('lineNumbers', value);

  /**
   * Whether, when indenting, the first N*tabSize spaces should be replaced by N
   * tabs. Default is false.
   */
  bool getIndentWithTabs() => getOption('indentWithTabs');

  /**
   * Whether, when indenting, the first N*tabSize spaces should be replaced by N
   * tabs.
   */
  void setIndentWithTabs(bool value) => setOption('indentWithTabs', value);

  /**
   * Whether editing is disabled.
   */
  bool getReadOnly() => getOption('readOnly');

  /**
   * This disables editing of the editor content by the user.
   */
  void setReadOnly(bool value) => setOption('readOnly', value);

  /**
   * The width of a tab character. Defaults to 4.
   */
  int getTabSize() => getOption('tabSize');

  /**
   * The width of a tab character.
   */
  void setTabSize(int value) => setOption('tabSize', value);

  /**
   * How many spaces a block (whatever that means in the edited language) should
   * be indented. The default is 2.
   */
  int getIndentUnit() => getOption('indentUnit');

  /**
   * How many spaces a block (whatever that means in the edited language) should
   * be indented.
   */
  void setIndentUnit(int value) => setOption('indentUnit', value);

  /**
   * If your code does something to change the size of the editor element
   * (window resizes are already listened for), or unhides it, you should
   * probably follow up by calling this method to ensure CodeMirror is still
   * looking as intended.
   */
  void refresh() => call('refresh');

  /**
   * Give the editor focus.
   */
  void focus() => call('focus');

  /**
   * Retrieve one end of the primary selection. start is a an optional string
   * indicating which end of the selection to return. It may be "from", "to",
   * "head" (the side of the selection that moves when you press shift+arrow),
   * or "anchor" (the fixed side of the selection). Omitting the argument is the
   * same as passing "head". A {line, ch} object will be returned.
   */
  Position getCursor([String start]) => new Position.fromProxy(
        start == null ? call('getCursor') : callArg('getCursor', start));

  /**
   * Add a new custom command to CodeMirror.
   */
  void addCommand(String name, CommandHandler callback) {
    context['CodeMirror']['commands'][name] = (_) {
      callback(this);
    };
  }
}

/**
 * Each editor is associated with an instance of [Doc], its document. A document
 * represents the editor content, plus a selection, an undo history, and a mode.
 * A document can only be associated with a single editor at a time. You can
 * create new documents by calling the
 * `CodeMirror.Doc(text, mode, firstLineNumber)` constructor. The last two
 * arguments are optional and can be used to set a mode for the document and
 * make it start at a line number other than 0, respectively.
 */
class Doc extends ProxyHolder {
  static JsObject _create(String text, String mode, int firstLineNumber) {
    if (firstLineNumber == null) {
      return new JsObject(context['CodeMirror']['Doc'], [text, mode]);
    } else {
      return new JsObject(context['CodeMirror']['Doc'], [text, mode, firstLineNumber]);
    }
  }

  Doc(String text, [String mode, int firstLineNumber]) :
    super(_create(text, mode, firstLineNumber));

  Doc.fromProxy(JsObject proxy) : super(proxy);

  String getValue() => call('getValue');

  void setValue(String value) => callArg('setValue', value);

  /**
   * Get the number of lines in the editor.
   */
  int lineCount() => call('lineCount');

  /**
   * Get the first line of the editor. This will usually be zero but for linked
   * sub-views, or documents instantiated with a non-zero first line, it might
   * return other values.
   */
  int firstCount() => call('firstCount');

  /**
   * Get the last line of the editor. This will usually be doc.lineCount() - 1,
   * but for linked sub-views, it might return other values.
   */
  int lastCount() => call('lastCount');

  /**
   * Get the content of line n.
   */
  String getLine(int n) => callArg('getLine', n);

  /**
   * Set the editor content as 'clean', a flag that it will retain until it is
   * edited, and which will be set again when such an edit is undone again.
   * Useful to track whether the content needs to be saved. This function is
   * deprecated in favor of changeGeneration, which allows multiple subsystems
   * to track different notions of cleanness without interfering.
   */
  void markClean() => call('markClean');

  /**
   * Returns a number that can later be passed to [isClean] to test whether any
   * edits were made (and not undone) in the meantime. If closeEvent is true,
   * the current history event will be ‘closed’, meaning it can't be combined
   * with further changes (rapid typing or deleting events are typically
   * combined).
   */
  int changeGeneration([bool closeEvent]) {
    return closeEvent == null ?
        call('changeGeneration') : callArg('changeGeneration', closeEvent);
  }

  /**
   * Returns whether the document is currently clean — not modified since
   * initialization or the last call to [markClean] if no argument is passed, or
   * since the matching call to [changeGeneration] if a generation value is
   * given.
   */
  bool isClean([int generation]) {
    return generation == null ? call('isClean') : callArg('isClean', generation);
  }

  /**
   * Retrieve one end of the primary selection. start is a an optional string
   * indicating which end of the selection to return. It may be "from", "to",
   * "head" (the side of the selection that moves when you press shift+arrow),
   * or "anchor" (the fixed side of the selection). Omitting the argument is the
   * same as passing "head". A {line, ch} object will be returned.
   */
  Position getCursor([String start]) => new Position.fromProxy(
        start == null ? call('getCursor') : callArg('getCursor', start));

  /**
   * Get the text between the given points in the editor, which should be
   * {line, ch} objects. An optional third argument can be given to indicate the
   * line separator string to use (defaults to "\n").
   */
  String getRange(Position from, Position to) {
    return callArgs('getRange', [from.toProxy(), to.toProxy()]);
  }

  /**
   * Fired whenever a change occurs to the document. changeObj has a similar
   * type as the object passed to the editor's "change" event.
   */
  Stream get onChange => onEvent('change');
}

/**
 * Both `line` and `ch` are 0-based.
 *
 * `{line, ch}`
 */
class Position {
  final int line;
  final int ch;

  Position(this.line, this.ch);

  Position.fromProxy(var obj) : line = obj['line'], ch = obj['ch'];

  JsObject toProxy() => jsify({'line': line, 'ch': ch});

  String toString() => '[${line}:${ch}]';
}

/**
 * A source span from a start position ([head]) to an end position ([anchor]);
 */
class Span {
  final Position head;
  final Position anchor;

  Span(this.head, this.anchor);

  Span.fromProxy(var obj) :
      head = new Position.fromProxy(obj['head']),
      anchor = new Position.fromProxy(obj['anchor']);

  String toString() => '${head}=>${anchor}]';
}

/**
 * A parent class for objects that can hold references to JavaScript objects.
 * It has convenience methods for invoking methods on the JavaScript proxy,
 * a method to add event listeners to the proxy, and a [dispose] method.
 * `dispose` only needs to be called if event listeners were added to an object.
 */
abstract class ProxyHolder {
  final JsObject jsProxy;
  final Map<String, JsEventListener> _events = {};

  ProxyHolder(this.jsProxy);

  dynamic call(String methodName) => jsProxy.callMethod(methodName);

  dynamic callArg(String methodName, var arg) =>
      jsProxy.callMethod(methodName, [arg]);

  dynamic callArgs(String methodName, List args) =>
      jsProxy.callMethod(methodName, args);

  Stream onEvent(String eventName, [bool twoArgs = false]) {
    if (!_events.containsKey(eventName)) {
      _events[eventName] = new JsEventListener(jsProxy, eventName,
          cvtEvent: (twoArgs ? (e) => e : null), twoArgs: twoArgs);
    }
    return _events[eventName].stream;
  }

  /**
   * This method should be called if any events listeners were added to the
   * object.
   */
  void dispose() {
    if (_events.isNotEmpty) {
      for (JsEventListener event in _events.values) {
        event.dispose();
      }
    }
  }
}
