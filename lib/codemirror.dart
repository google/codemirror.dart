// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library codemirror;

import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'src/js_utils.dart';

// TODO: find, replace

/// A parameter type into the [CodeMirror.addCommand] method.
typedef CommandHandler = void Function(CodeMirror editor);

/// A parameter type into the [Doc.eachLine] method.
typedef LineHandler = void Function(LineHandle line);

/// A parameter type into the [Doc.extendSelectionsBy] method.
typedef SelectionExtender = Position Function(Span range, int i);

/// A wrapper around the CodeMirror editor.
class CodeMirror extends ProxyHolder {
  static final List<String> THEMES = const [
    '3024-day',
    '3024-night',
    'abcdef',
    'ambiance-mobile',
    'ambiance',
    'base16-dark',
    'base16-light',
    'blackboard',
    'cobalt',
    'colorforth',
    'darcula',
    'dracula',
    'duotone-dark',
    'duotone-light',
    'eclipse',
    'elegant',
    'erlang-dark',
    'gruvbox-dark',
    'hopscotch',
    'icecoder',
    'idea',
    'isotope',
    'lesser-dark',
    'liquibyte',
    'lucario',
    'material',
    'mbo',
    'mdn-like',
    'midnight',
    'monokai',
    'neat',
    'neo',
    'night',
    'nord',
    'oceanic-next',
    'panda-syntax',
    'paraiso-dark',
    'paraiso-light',
    'pastel-on-dark',
    'railscasts',
    'rubyblue',
    'seti',
    'shadowfox',
    'solarized',
    'ssms',
    'the-matrix',
    'tomorrow-night-bright',
    'tomorrow-night-eighties',
    'ttcn',
    'twilight',
    'vibrant-ink',
    'xq-dark',
    'xq-light',
    'zenburn',
    'yonce',
    'yeti',
  ];

  static final List<String> KEY_MAPS = const [
    'default',
    'emacs',
    'sublime',
    'vim',
  ];

  static JsObject get _cm => context['CodeMirror'];

  static Map<JsObject, CodeMirror> _instances = {};

  static List<String> get MODES =>
      List.from(keys(_cm['modes']).where((modeName) => modeName != 'null'));

  static List<String> get MIME_MODES => List.from(keys(_cm['mimeModes']));

  static List<String> get COMMANDS => List.from(keys(_cm['commands']));

  /// It contains a string that indicates the version of the library. This is a
  /// triple of integers "major.minor.patch", where patch is zero for releases,
  /// and something else (usually one) for dev snapshots.
  static String get version => _cm['version'];

  static ModeInfo findModeByExtension(String ext) =>
      ModeInfo(_cm.callMethod('findModeByExtension', [ext]));

  static ModeInfo findModeByMime(String mime) =>
      ModeInfo(_cm.callMethod('findModeByMIME', [mime]));

  static ModeInfo findModeByFileName(String name) =>
      ModeInfo(_cm.callMethod('findModeByFileName', [name]));

  static ModeInfo findModeByName(String name) =>
      ModeInfo(_cm.callMethod('findModeByName', [name]));

  /// If you want to define extra methods in terms of the CodeMirror API, it is
  /// possible to use defineExtension. This will cause the given value (usually a
  /// method) to be added to all CodeMirror instances created from then on.
  static void defineExtension(String name, dynamic value) {
    _cm.callMethod('defineExtension', [name, value]);
  }

  /// Like defineExtension, but the method will be added to the interface for Doc
  /// objects instead.
  static void defineDocExtension(String name, dynamic value) {
    _cm.callMethod('defineDocExtension', [name, value]);
  }

  /// Registers a helper value with the given name in the given namespace (type).
  /// This is used to define functionality that may be looked up by mode. Will
  /// create (if it doesn't already exist) a property on the CodeMirror object
  /// for the given type, pointing to an object that maps names to values. I.e.
  /// after doing CodeMirror.registerHelper("hint", "foo", myFoo), the value
  /// CodeMirror.hint.foo will point to myFoo.
  static void registerHelper(String type, String mode, dynamic helper) {
    _cm.callMethod('registerHelper', [type, mode, helper]);
  }

//  ///
//  /// Acts like registerHelper, but also registers this helper as 'global',
//  /// meaning that it will be included by getHelpers whenever the given
//  /// predicate returns true when called with the local mode and editor.
//
//  static void registerGlobalHelper(String type, String mode,
//      Function predicate, dynamic helper) {
//    // predicate: fn(mode, CodeMirror)
//    // TODO: value may be a Function? always a function?
//  }

  static JsObject _createFromElement(Element element, Map options) {
    if (options == null) {
      return JsObject(_cm, [element]);
    } else {
      return JsObject(_cm, [element, jsify(options)]);
    }
  }

  static JsObject _createFromTextArea(TextAreaElement textArea, Map options) {
    List args = <dynamic>[textArea];
    if (options != null) args.add(jsify(options));
    return _cm.callMethod('fromTextArea', args);
  }

  /// Add a new custom command to CodeMirror.
  static void addCommand(String name, CommandHandler callback) {
    _cm['commands'][name] = (JsObject obj) {
      var editor = CodeMirror.fromJsObject(obj);
      callback(editor);
    };
  }

  Doc _doc;

  /// Create a new CodeMirror editor in the given element. See
  /// http://codemirror.net/doc/manual.html#config for valid options values.
  CodeMirror.fromElement(Element element, {Map options})
      : super(_createFromElement(element, options)) {
    _instances[jsProxy] = this;
  }

  /// Create a new CodeMirror editor from the given JsObject. This will return an
  /// existing Dart `CodeMirror` object if there is already one for the given
  /// JavaScript proxy.
  factory CodeMirror.fromJsObject(JsObject object) {
    if (_instances.containsKey(object)) {
      return _instances[object];
    } else {
      return CodeMirror._fromJsObject(object);
    }
  }

  CodeMirror._fromJsObject(JsObject object) : super(object) {
    _instances[jsProxy] = this;
  }

  /// The method provides another way to initialize an editor. It takes a
  /// textarea DOM node as first argument and an optional configuration object as
  /// second. It will replace the textarea with a CodeMirror instance, and wire
  /// up the form of that textarea (if any) to make sure the editor contents are
  /// put into the textarea when the form is submitted. The text in the textarea
  /// will provide the content for the editor. A CodeMirror instance created this
  /// way has three additional methods: `save`, `toTextArea`, and `getTextArea`.
  CodeMirror.fromTextArea(TextAreaElement textArea, {Map options})
      : super(_createFromTextArea(textArea, options)) {
    _instances[jsProxy] = this;
  }

  /// Fires every time the content of the editor is changed.
  Stream get onChange => onEvent('change', argCount: 2);

  /// Will be fired when the cursor or selection moves, or any change is made to
  /// the editor content.
  Stream get onCursorActivity => onEvent('cursorActivity');

  /// Fired when a mouse is clicked. You can preventDefault the event to signal
  /// that CodeMirror should do no further handling.
  Stream<MouseEvent> get onMouseDown =>
      onEvent('mousedown', argCount: 2).cast<MouseEvent>();

  /// Fired when a mouse is double-clicked. You can preventDefault the event to
  /// signal that CodeMirror should do no further handling.
  Stream<MouseEvent> get onDoubleClick =>
      onEvent('dblclick', argCount: 2).cast<MouseEvent>();

  /// Fires when the editor gutter (the line-number area) is clicked.
  Stream<int> get onGutterClick => onEvent<int>('gutterClick', argCount: 4);

  /// Retrieve the currently active document from an editor.
  Doc getDoc() {
    if (_doc == null) {
      _doc = Doc.fromProxy(call('getDoc'));
    }
    return _doc;
  }

  /// Attach a new document to the editor.
  void swapDoc(Doc doc) {
    _doc = doc;
    callArg('swapDoc', doc.jsProxy);
  }

  /// Retrieves the current value of the given option for this editor instance.
  dynamic getOption(String option) => callArg('getOption', option);

  /// Change the configuration of the editor. [option] should the name of an
  /// option, and value should be a valid value for that option.
  void setOption(String option, dynamic value) =>
      callArgs('setOption', [option, value]);

  String getTheme() => getOption('theme');

  void setTheme(String theme) => setOption('theme', theme);

  String getMode() => getOption('mode');

  void setMode(String mode) => setOption('mode', mode);

  /// Return the current key map.
  String getKeyMap() => getOption('keyMap');

  /// Valid options are `default`, `vim`, `emacs`, and `sublime`.
  void setKeyMap(String value) => setOption('keyMap', value);

  /// Whether to show line numbers to the left of the editor.
  bool getLineNumbers() => getOption('lineNumbers');

  /// Whether to show line numbers to the left of the editor.
  void setLineNumbers(bool value) => setOption('lineNumbers', value);

  /// Get the content of line n.
  String getLine(int n) => callArg('getLine', n);

  /// Whether, when indenting, the first N*tabSize spaces should be replaced by N
  /// tabs. Default is false.
  bool getIndentWithTabs() => getOption('indentWithTabs');

  /// Whether, when indenting, the first N*tabSize spaces should be replaced by N
  /// tabs.
  void setIndentWithTabs(bool value) => setOption('indentWithTabs', value);

  /// Whether editing is disabled.
  bool getReadOnly() =>
      getOption('readOnly') == true ||
      getOption('readOnly') == 'true' ||
      getOption('readOnly') == 'nocursor';

  /// This disables editing of the editor content by the user.
  void setReadOnly(bool value, [bool noCursor = false]) {
    if (value) {
      if (noCursor) {
        setOption('readOnly', 'nocursor');
      } else {
        setOption('readOnly', value);
      }
    } else {
      setOption('readOnly', value);
    }
  }

  /// The width of a tab character. Defaults to 4.
  int getTabSize() => getOption('tabSize');

  /// The width of a tab character.
  void setTabSize(int value) => setOption('tabSize', value);

  /// How many spaces a block (whatever that means in the edited language) should
  /// be indented. The default is 2.
  int getIndentUnit() => getOption('indentUnit');

  /// How many spaces a block (whatever that means in the edited language) should
  /// be indented.
  void setIndentUnit(int value) => setOption('indentUnit', value);

  /// If your code does something to change the size of the editor element
  /// (window resizes are already listened for), or unhides it, you should
  /// probably follow up by calling this method to ensure CodeMirror is still
  /// looking as intended.
  void refresh() => call('refresh');

  /// Give the editor focus.
  void focus() => call('focus');

  /// Returns the input field for the editor. Will be a textarea or an editable
  /// div, depending on the value of the inputStyle option.
  Element getInputField() => call('getInputField');

  /// Retrieve one end of the primary selection. [start] is a an optional string
  /// indicating which end of the selection to return. It may be "from", "to",
  /// "head" (the side of the selection that moves when you press shift+arrow),
  /// or "anchor" (the fixed side of the selection). Omitting the argument is the
  /// same as passing "head". A {line, ch} object will be returned.

  Position getCursor([String start]) => Position.fromProxy(
      start == null ? call('getCursor') : callArg('getCursor', start));

  /// Runs the command with the given name on the editor.

  void execCommand(String name) {
    callArg('execCommand', name);
  }

  /// Sets the gutter marker for the given gutter (identified by its CSS class,
  /// see the gutters option) to the given value. Value can be either null, to
  /// clear the marker, or a DOM element, to set it. The DOM element will be
  /// shown in the specified gutter next to the specified line.
  void setGutterMarker(int line, String gutterID, Element value) {
    callArgs('setGutterMarker', [line, gutterID, value]);
  }

  /// Remove all gutter markers in the gutter with the given ID.
  void clearGutter(String gutterID) {
    callArg('clearGutter', gutterID);
  }

  /// Puts node, which should be an absolutely positioned DOM node, into the
  /// editor, positioned right below the given {line, ch} position. When
  /// scrollIntoView is true, the editor will ensure that the entire node is
  /// visible (if possible). To remove the widget again, simply use DOM methods
  /// (move it somewhere else, or call removeChild on its parent).
  void addWidget(Position pos, Element node, [bool scrollIntoView = false]) {
    callArgs('addWidget', [pos.toProxy(), node, scrollIntoView]);
  }

  /// Adds a line widget, an element shown below a line, spanning the whole of
  /// the editor's width, and moving the lines below it downwards. [line] should
  /// be either an integer or a [LineHandle], and node should be a DOM node,
  /// which will be displayed below the given line.
  ///
  /// [coverGutter]: whether the widget should cover the gutter.
  /// [noHScroll]: whether the widget should stay fixed in the face of horizontal
  /// scrolling.
  /// [above]: causes the widget to be placed above instead of below the text of
  /// the line.
  /// [handleMouseEvents]: determines whether the editor will capture mouse and
  /// drag events occurring in this widget. Default is false — the events will be
  /// left alone for the default browser handler, or specific handlers on the
  /// widget, to capture.
  /// [insertAt]: by default, the widget is added below other widgets for the
  /// line. This option can be used to place it at a different position (zero for
  /// the top, N to put it after the Nth other widget). Note that this only has
  /// effect once, when the widget is created.
  LineWidget addLineWidget(dynamic line, Element node,
      {bool coverGutter,
      bool noHScroll,
      bool above,
      bool handleMouseEvents,
      int insertAt}) {
    Map options = {};

    if (coverGutter != null) options['coverGutter'] = coverGutter;
    if (noHScroll != null) options['noHScroll'] = noHScroll;
    if (above != null) options['above'] = above;
    if (handleMouseEvents != null) {
      options['handleMouseEvents'] = handleMouseEvents;
    }
    if (insertAt != null) options['insertAt'] = insertAt;

    var l = line is LineHandle ? line.jsProxy : line;
    return LineWidget(callArgs('addLineWidget', [l, node, jsify(options)]));
  }

  /// Set a CSS class name for the given line. [line] can be a number or a
  /// [LineHandle]. [where] determines to which element this class should be
  /// applied, can can be one of "text" (the text element, which lies in front of
  /// the selection), "background" (a background element that will be behind the
  /// selection), "gutter" (the line's gutter space), or "wrap" (the wrapper node
  /// that wraps all of the line's elements, including gutter elements).
  /// [cssClass] should be the name of the class to apply.
  LineHandle addLineClass(dynamic line, String where, String cssClass) {
    var l = line is LineHandle ? line.jsProxy : line;
    return LineHandle(callArgs('addLineClass', [l, where, cssClass]));
  }

  /// Remove a CSS class from a line. [line] can be a [LineHandle] or number.
  /// [where] should be one of "text", "background", or "wrap" (see
  /// [addLineClass]). [cssClass] can be left off to remove all classes for the
  /// specified node, or be a string to remove only a specific class.
  LineHandle removeLineClass(dynamic line, String where, [String cssClass]) {
    var l = line is LineHandle ? line.jsProxy : line;
    if (cssClass == null) {
      return LineHandle(callArgs('removeLineClass', [l, where]));
    } else {
      return LineHandle(callArgs('removeLineClass', [l, where, cssClass]));
    }
  }

  /// Retrieves information about the token the current mode found before the
  /// given position.
  ///
  /// If [precise] is true, the token will be guaranteed to be accurate based on
  /// recent edits. If false or not specified, the token will use cached state
  /// information, which will be faster but might not be accurate if edits were
  /// recently made and highlighting has not yet completed.
  Token getTokenAt(Position pos, [bool precise]) {
    var r = precise == null
        ? callArg('getTokenAt', pos.toProxy())
        : callArgs('getTokenAt', [pos.toProxy(), precise]);
    return Token.fromProxy(r);
  }

  /// This is similar to getTokenAt, but collects all tokens for a given line
  /// into an array. It is much cheaper than repeatedly calling getTokenAt,
  /// which re-parses the part of the line before the token for every call.
  List<Token> getLineTokens(int line, [bool precise]) {
    var result = precise != null
        ? callArgs('getLineTokens', [line, precise])
        : callArg('getLineTokens', line);
    if (result is List) {
      return List.from(result.map((t) => Token.fromProxy(t)));
    } else {
      return [];
    }
  }

  /// This is a (much) cheaper version of getTokenAt useful for when you just
  /// need the type of the token at a given position, and no other information.
  /// Will return null for unstyled tokens, and a string, potentially containing
  /// multiple space-separated style names, otherwise.
  String getTokenTypeAt(Position pos) => callArg('getTokenTypeAt', pos);

  /// Programmatically set the size of the editor (overriding the applicable CSS
  /// rules). [width] and [height] can be either numbers (interpreted as pixels)
  /// or CSS units ("100%", for example). You can pass `null` for either of them
  /// to indicate that that dimension should not be changed.
  void setSize(num width, num height) => callArgs('setSize', [width, height]);

  /// Scroll the editor to a given (pixel) position. Both arguments may be left
  /// as null or undefined to have no effect.
  void scrollTo(num x, num y) => callArgs('scrollTo', [x, y]);

  /// Get a [ScrollInfo] object that represents the current scroll position, the
  /// size of the scrollable area, and the size of the visible area (minus
  /// scrollbars).
  ScrollInfo getScrollInfo() => ScrollInfo(call('getScrollInfo'));

  /// Scrolls the given position into view. The margin parameter is optional.
  /// When given, it indicates the amount of vertical pixels around the given
  /// area that should be made visible as well.
  void scrollIntoView(int line, int ch, {int margin}) {
    if (margin != null) {
      callArgs('scrollIntoView', [
        JsObject.jsify({'line': line, 'ch': ch}),
        margin,
      ]);
    } else {
      callArgs('scrollIntoView', [
        JsObject.jsify({'line': line, 'ch': ch}),
      ]);
    }
  }

  /// Fetch the set of applicable helper values for the given position. Helpers
  /// provide a way to look up functionality appropriate for a mode. The type
  /// argument provides the helper namespace (see registerHelper), in which the
  /// values will be looked up. When the mode itself has a property that
  /// corresponds to the type, that directly determines the keys that are used to
  /// look up the helper values (it may be either a single string, or an array of
  /// strings). Failing that, the mode's helperType property and finally the
  /// mode's name are used.
  ///
  /// For example, the JavaScript mode has a property fold containing "brace".
  /// When the brace-fold addon is loaded, that defines a helper named brace in
  /// the fold namespace. This is then used by the foldcode addon to figure out
  /// that it can use that folding function to fold JavaScript code.
  ///
  /// When any 'global' helpers are defined for the given namespace, their
  /// predicates are called on the current mode and editor, and all those that
  /// declare they are applicable will also be added to the array that is
  /// returned.
  List<JsObject> getHelpers(Position pos, String type) {
    return List.from(callArgs('getHelpers', [pos.toProxy(), type]));
  }

  /// Returns the first applicable helper value.
  JsObject getHelper(Position pos, String type) {
    return callArgs('getHelper', [pos.toProxy(), type]);
  }

  /// Copy the content of the editor into the textarea.
  ///
  /// Only available if the CodeMirror instance was created using the
  /// `CodeMirror.fromTextArea` constructor.
  void save() => call('save');

  /// Remove the editor, and restore the original textarea (with the editor's
  /// current content).
  ///
  /// Only available if the CodeMirror instance was created using the
  /// CodeMirror.fromTextArea` constructor.
  void toTextArea() => call('toTextArea');

  /// Returns the textarea that the instance was based on.
  ///
  /// Only available if the CodeMirror instance was created using the
  /// `CodeMirror.fromTextArea` constructor.
  TextAreaElement getTextArea() => call('getTextArea');

  /// If you create and discard a large number of `CodeMirror` instances, you
  /// should call [dispose] after finishing with each one.
  void dispose() {
    super.dispose();

    // Remove registrations from the map.
    _instances.remove(jsProxy);
  }
}

/// Each editor is associated with an instance of [Doc], its document. A document
/// represents the editor content, plus a selection, an undo history, and a mode.
/// A document can only be associated with a single editor at a time. You can
/// create new documents by calling the
/// `CodeMirror.Doc(text, mode, firstLineNumber)` constructor. The last two
/// arguments are optional and can be used to set a mode for the document and
/// make it start at a line number other than 0, respectively.
class Doc extends ProxyHolder {
  static JsObject _create(String text, String mode, int firstLineNumber) {
    if (firstLineNumber == null) {
      return JsObject(context['CodeMirror']['Doc'], [text, mode]);
    } else {
      return JsObject(
          context['CodeMirror']['Doc'], [text, mode, firstLineNumber]);
    }
  }

  CodeMirror _editor;

  Doc(String text, [String mode, int firstLineNumber])
      : super(_create(text, mode, firstLineNumber));

  Doc.fromProxy(JsObject proxy) : super(proxy);

  CodeMirror getEditor() {
    if (_editor == null) {
      _editor = CodeMirror.fromJsObject(call('getEditor'));
    }
    return _editor;
  }

  /// Get the current editor content. You can pass it an optional argument to
  /// specify the string to be used to separate lines (defaults to "\n").
  String getValue([String separator]) => callArg('getValue', separator);

  /// Set the editor content.
  void setValue(String value) => callArg('setValue', value);

  /// Get the number of lines in the editor.
  int lineCount() => call('lineCount');

  /// Get the first line of the editor. This will usually be zero but for linked
  /// sub-views, or documents instantiated with a non-zero first line, it might
  /// return other values.
  int firstLine() => call('firstLine');

  /// Get the last line of the editor. This will usually be doc.lineCount() - 1,
  /// but for linked sub-views, it might return other values.
  int lastLine() => call('lastLine');

  /// Get the content of line n.
  String getLine(int n) => callArg('getLine', n);

  /// Iterate over the whole document, or if [start] and [end] line numbers are
  /// given, the range from start up to (not including) end, and call f for each
  /// line, passing the line handle. This is a faster way to visit a range of
  /// line handlers than calling getLineHandle for each of them. Note that line
  /// handles have a text property containing the line's content (as a string).
  void eachLine(LineHandler callback, {int start, int end}) {
    start ??= firstLine();
    end ??= lastLine() + 1;
    callArgs('eachLine', [
      start,
      end,
      (JsObject line) {
        callback(LineHandle(line));
      }
    ]);
  }

  /// Return `true` if any text is selected.
  bool somethingSelected() => call('somethingSelected');

  /// Get the currently selected code. Optionally pass a line separator to put
  /// between the lines in the output. When multiple selections are present, they
  /// are concatenated with instances of [lineSep] in between.
  String getSelection([String lineSep]) => callArg('getSelection', lineSep);

  /// Set a single selection range. anchor and head should be {line, ch} objects.
  /// head defaults to anchor when not given. These options are supported:
  ///
  /// `scroll`: determines whether the selection head should be scrolled into
  /// view. Defaults to true.
  ///
  /// `origin`: detemines whether the selection history event may be merged with
  /// the previous one. When an origin starts with the character +, and the last
  /// recorded selection had the same origin and was similar (close in time, both
  /// collapsed or both non-collapsed), the new one will replace the old one.
  /// When it starts with///, it will always replace the previous event (if that
  /// had the same origin). Built-in motion uses the "+move" origin.
  ///
  /// `bias`: determine the direction into which the selection endpoints should
  /// be adjusted when they fall inside an atomic range. Can be either -1
  /// (backward) or 1 (forward). When not given, the bias will be based on the
  /// relative position of the old selection—the editor will try to move further
  /// away from that, to prevent getting stuck.
  void setSelection(Position anchor, {Position head, Map options}) {
    callArgs('setSelection',
        [anchor.toProxy(), head == null ? null : head.toProxy(), options]);
  }

  /// Replace the selection(s) with the given string. By default, the new
  /// selection ends up after the inserted text. The optional select argument can
  /// be used to change this. Passing `around`: will cause the new text to be
  /// selected; `start`: will collapse the selection to the start of the inserted
  /// text.
  void replaceSelection(String replacement, [String select]) {
    callArgs('replaceSelection',
        select != null ? [replacement, select] : [replacement]);
  }

  /// Returns an array containing a string for each selection, representing the
  /// content of the selections.
  Iterable<String> getSelections([String lineSep]) =>
      callArg('getSelections', lineSep).cast<String>();

  /// Sets a new set of selections. There must be at least one selection in the
  /// given array. When [primary] is a number, it determines which selection is
  /// the primary one. When it is not given, the primary index is taken from
  /// the previous selection, or set to the last range if the previous
  /// selection had less ranges than the new one. Supports the same
  /// options as [setSelection].
  void setSelections(Iterable<Span> ranges, {int primary, Map options}) {
    callArgs('setSelections', [
      JsArray.from(ranges.map((Span range) => range.toProxy())),
      primary,
      options
    ]);
  }

  /// The length of the given array should be the same as the number of active
  /// selections. Replaces the content of the selections with the strings in
  /// the array. The select argument works the same as in [replaceSelection].
  void replaceSelections(Iterable<String> replacement, {String select}) {
    callArgs('replaceSelections',
        select != null ? [jsify(replacement), select] : [jsify(replacement)]);
  }

  /// Adds a new selection to the existing set of selections, and makes it the
  /// primary selection.
  void addSelection({Position anchor, Position head}) {
    head ??= anchor;
    callArgs('addSelection', [anchor.toProxy(), head.toProxy()]);
  }

  /// Similar to [setSelection], but will, if shift is held or the extending flag
  /// is set, move the head of the selection while leaving the anchor at its
  /// current place. [to] is optional, and can be passed to ensure a region (for
  /// example a word or paragraph) will end up selected (in addition to whatever
  /// lies between that region and the current anchor). When multiple selections
  /// are present, all but the primary selection will be dropped by this method.
  /// Supports the same options as [setSelection].
  void extendSelection(Position from, [Position to, Map options]) {
    callArgs('extendSelection', [from.toProxy(), to?.toProxy(), options]);
  }

  /// An equivalent of [extendSelection] that acts on all selections at once.
  void extendSelections(List<Position> heads, [Map options]) {
    callArgs('extendSelections',
        [JsArray.from(heads.map((Position head) => head.toProxy())), options]);
  }

  /// Applies the given function to all existing selections, and calls
  /// [extendSelections] on the result.
  void extendSelectionsBy(SelectionExtender f, [Map options]) {
    callArgs('extendSelectionsBy', [
      (JsObject obj, int i) => f(Span.fromProxy(obj), i).toProxy(),
      options
    ]);
  }

  /// Sets or clears the 'extending' flag, which acts similar to the shift key,
  /// in that it will cause cursor movement and calls to extendSelection to
  /// leave the selection anchor in place.
  void setExtending(bool value) {
    callArg('setExtending', value);
  }

  /// Get the value of the 'extending' flag.
  bool getExtending() => call('getExtending');

  /// Retrieves a list of all current selections.
  ///
  /// These will always be sorted,
  /// and never overlap (overlapping selections are merged). Each object in the
  /// array contains `anchor` and `head` properties referring
  /// to `{line, ch}` objects.
  Iterable<Span> listSelections() {
    return call('listSelections').map((JsObject selection) {
      return Span.fromProxy(selection);
    });
  }

  /// Replace the part of the document between [from] and [to] with the given
  /// string. [to] can be left off to simply insert the string at position
  /// [from].
  ///
  /// When origin is given, it will be passed on to "change" events, and its
  /// first letter will be used to determine whether this change can be merged
  /// with previous history events, in the way described for selection origins.
  void replaceRange(String replacement, Position from,
      [Position to, String origin]) {
    callArgs(
        'replaceRange',
        origin != null
            ? [replacement, from.toProxy(), to.toProxy(), origin]
            : [replacement, from.toProxy(), to == null ? null : to.toProxy()]);
  }

  /// Set the editor content as 'clean', a flag that it will retain until it is
  /// edited, and which will be set again when such an edit is undone again.
  /// Useful to track whether the content needs to be saved. This function is
  /// deprecated in favor of changeGeneration, which allows multiple subsystems
  /// to track different notions of cleanness without interfering.
  void markClean() => call('markClean');

  /// Returns a number that can later be passed to [isClean] to test whether any
  /// edits were made (and not undone) in the meantime. If closeEvent is true,
  /// the current history event will be 'closed', meaning it can't be combined
  /// with further changes (rapid typing or deleting events are typically
  /// combined).
  int changeGeneration([bool closeEvent]) {
    return closeEvent == null
        ? call('changeGeneration')
        : callArg('changeGeneration', closeEvent);
  }

  /// Returns whether the document is currently clean, not modified since
  /// initialization or the last call to [markClean] if no argument is passed, or
  /// since the matching call to [changeGeneration] if a generation value is
  /// given.
  bool isClean([int generation]) {
    return generation == null
        ? call('isClean')
        : callArg('isClean', generation);
  }

  // History-related methods.

  /// Undo one edit (if any undo events are stored).
  void undo() => call('undo');

  /// Redo one undone edit.
  void redo() => call('redo');

  /// Undo one edit or selection change.
  void undoSelection() => call('undoSelection');

  /// Redo one undone edit or selection change.
  void redoSelection() => call('redoSelection');

  /// Returns an object with `{'undo': int, 'redo': int}` properties, both of
  /// which hold integers, indicating the amount of stored undo and redo
  /// operations.
  Map<String, int> historySize() {
    JsObject result = call('historySize');

    return {
      'undo': result['undo'],
      'redo': result['redo'],
    };
  }

  /// Clears the editor's undo history.
  void clearHistory() => call('clearHistory');

  /// Get a (JSON-serializeable) representation of the undo history.
  JsObject getHistory() => call('getHistory');

  /// Replace the editor's undo history with the one provided, which must be a
  /// value as returned by [getHistory]. Note that this will have entirely
  /// undefined results if the editor content isn't also the same as it was when
  /// [getHistory] was called.
  void setHistory(JsObject history) => callArg('setHistory', history);

  /// Retrieve one end of the primary selection. start is a an optional string
  /// indicating which end of the selection to return. It may be "from", "to",
  /// "head" (the side of the selection that moves when you press shift+arrow),
  /// or "anchor" (the fixed side of the selection). Omitting the argument is the
  /// same as passing "head". A {line, ch} object will be returned.
  Position getCursor([String start]) => Position.fromProxy(
      start == null ? call('getCursor') : callArg('getCursor', start));

  /// Set the cursor position. You can either pass a single {line, ch} object, or
  /// the line and the character as two separate parameters. Will replace all
  /// selections with a single, empty selection at the given position. The
  /// supported options are the same as for setSelection.
  void setCursor(Position pos, {Map options}) {
    callArgs('setCursor', [pos.toProxy(), options]);
  }

  /// Get the text between the given points in the editor. An optional third
  /// argument can be given to indicate the line separator string to use
  /// (defaults to "\n").
  String getRange(Position from, Position to, [String separator]) {
    return callArgs('getRange', [from.toProxy(), to.toProxy(), separator]);
  }

  /// Calculates and returns a `Position` object for a zero-based index who's
  /// value is relative to the start of the editor's text. If the index is out of
  /// range of the text then the returned object is clipped to start or end of
  /// the text respectively.
  Position posFromIndex(int index) =>
      Position.fromProxy(callArg('posFromIndex', index));

  /// The reverse of [posFromIndex].
  int indexFromPos(Position pos) => callArg('indexFromPos', pos.toProxy());

  /// Can be used to mark a range of text with a specific CSS class name.
  ///
  /// [className]: assigns a CSS class to the marked stretch of text.
  /// [inclusiveLeft]: determines whether text inserted on the left of the marker
  /// will end up inside or outside of it.
  /// [inclusiveRight]: like inclusiveLeft, but for the right side.
  /// [atomic]: atomic ranges act as a single unit when cursor movement is
  /// concerned — i.e. it is impossible to place the cursor inside of them. In
  /// atomic ranges, inclusiveLeft and inclusiveRight have a different meaning —
  /// they will prevent the cursor from being placed respectively directly before
  /// and directly after the range.
  /// [collapsed]: collapsed ranges do not show up in the display. Setting a
  /// range to be collapsed will automatically make it atomic.
  /// [clearOnEnter]: when enabled, will cause the mark to clear itself whenever
  /// the cursor enters its range. This is mostly useful for text - replacement
  /// widgets that need to 'snap open' when the user tries to edit them. The
  /// "clear" event fired on the range handle can be used to be notified when
  /// this happens.
  /// [clearWhenEmpty]: determines whether the mark is automatically cleared when
  /// it becomes empty. Default is true.
  /// [replacedWith]: use a given node to display this range. Implies both
  /// collapsed and atomic. The given DOM node must be an inline element (as
  /// opposed to a block element).
  /// [handleMouseEvents]: when replacedWith is given, this determines whether
  /// the editor will capture mouse and drag events occurring in this widget.
  /// Default is false — the events will be left alone for the default browser
  /// handler, or specific handlers on the widget, to capture.
  /// [readOnly]: a read-only span can, as long as it is not cleared, not be
  /// modified except by calling setValue to reset the whole document. Note:
  /// adding a read-only span currently clears the undo history of the editor,
  /// because existing undo events being partially nullified by read-only spans
  /// would corrupt the history (in the current implementation).
  /// [addToHistory]: when set to true (default is false), adding this marker
  /// will create an event in the undo history that can be individually undone
  /// (clearing the marker).
  /// [startStyle]: can be used to specify an extra CSS class to be applied to
  /// the leftmost span that is part of the marker.
  /// [endStyle]: equivalent to startStyle, but for the rightmost span.
  /// [css] a string of CSS to be applied to the covered text. For example
  /// "color: #fe3".
  /// [title]: when given, will give the nodes created for this span a HTML title
  /// attribute with the given value.
  /// [shared]: when the target document is linked to other documents, you can
  /// set shared to true to make the marker appear in all documents. By default,
  /// a marker appears only in its target document.
  TextMarker markText(Position from, Position to,
      {String className,
      bool inclusiveLeft,
      bool inclusiveRight,
      bool atomic,
      bool collapsed,
      bool clearOnEnter,
      bool clearWhenEmpty,
      Element replacedWith,
      bool handleMouseEvents,
      bool readOnly,
      bool addToHistory,
      String startStyle,
      String endStyle,
      String css,
      String title,
      bool shared}) {
    Map options = {};

    if (className != null) options['className'] = className;
    if (inclusiveLeft != null) options['inclusiveLeft'] = inclusiveLeft;
    if (inclusiveRight != null) options['inclusiveRight'] = inclusiveRight;
    if (atomic != null) options['atomic'] = atomic;
    if (collapsed != null) options['collapsed'] = collapsed;
    if (clearOnEnter != null) options['clearOnEnter'] = clearOnEnter;
    if (clearWhenEmpty != null) options['clearWhenEmpty'] = clearWhenEmpty;
    if (replacedWith != null) options['replacedWith'] = replacedWith;
    if (handleMouseEvents != null) {
      options['handleMouseEvents'] = handleMouseEvents;
    }
    if (readOnly != null) options['readOnly'] = readOnly;
    if (addToHistory != null) options['addToHistory'] = addToHistory;
    if (startStyle != null) options['startStyle'] = startStyle;
    if (endStyle != null) options['endStyle'] = endStyle;
    if (css != null) options['css'] = css;
    if (title != null) options['title'] = title;
    if (shared != null) options['shared'] = shared;

    return TextMarker(
        callArgs('markText', [from.toProxy(), to.toProxy(), jsify(options)]));
  }

  /// Inserts a bookmark, a handle that follows the text around it as it is being
  /// edited, at the given position. A bookmark has two methods find() and
  /// clear(). The first returns the current position of the bookmark, if it is
  /// still in the document, and the second explicitly removes the bookmark.
  ///
  /// [widget] can be used to display a DOM node at the current location of the
  /// bookmark (analogous to the replacedWith option to markText). [insertLeft]:
  /// by default, text typed when the cursor is on top of the bookmark will end
  /// up to the right of the bookmark. Set this option to true to make it go to
  /// the left instead. [shared]: when the target document is linked to other
  /// documents, you can set shared to true to make the marker appear in all
  /// documents. By default, a marker appears only in its target document.
  TextMarker setBookmark(Position pos,
      {Element widget, bool insertLeft, bool shared}) {
    Map options = {};

    if (widget != null) options['widget'] = widget;
    if (insertLeft != null) options['insertLeft'] = insertLeft;
    if (shared != null) options['shared'] = shared;

    return TextMarker(callArgs('setBookmark', [pos.toProxy(), jsify(options)]));
  }

  /// Returns an array of all the bookmarks and marked ranges found between the
  /// given positions.
  List<TextMarker> findMarks(Position from, Position to) {
    var result = callArgs('findMarks', [from.toProxy(), to.toProxy()]);
    if (result is! List) return [];
    return List.from(result.map((mark) => TextMarker(mark)));
  }

  /// Returns an array of all the bookmarks and marked ranges present at the
  /// given position.
  List<TextMarker> findMarksAt(Position pos) {
    var result = callArg('findMarksAt', pos.toProxy());
    if (result is! List) return [];
    return List.from(result.map((mark) => TextMarker(mark)));
  }

  /// Returns an array containing all marked ranges in the document.
  List<TextMarker> getAllMarks() {
    var result = call('getAllMarks');
    if (result is! List) return [];
    return List.from(result.map((mark) => TextMarker(mark)));
  }

  /// Gets the (outer) mode object for the editor. Note that this is distinct
  /// from getOption("mode"), which gives you the mode specification, rather than
  /// the resolved, instantiated mode object.
  ///
  /// The returned mode is a `JsObject`.
  dynamic getMode() => call('getMode');

  /// Return the name of the current mode.
  String getModeName() => getMode()['name'];

  /// Gets the inner mode at a given position. This will return the same as
  /// getMode for simple modes, but will return an inner mode for nesting modes
  /// (such as htmlmixed).
  ///
  /// The returned mode is a `JsObject`.
  dynamic getModeAt(Position pos) =>
      getEditor().callArg('getModeAt', pos.toProxy());

  /// Return the name of the mode at the given position.
  String getModeNameAt(Position pos) => getModeAt(pos)['name'];

  /// Fetches the line handle for the given line number.
  LineHandle getLineHandle(int line) {
    return LineHandle(callArg('getLineHandle', line));
  }

  /// Given a line handle, returns the current position of that line (or `null`
  /// when it is no longer in the document).
  int getLineNumber(LineHandle handle) {
    return callArg('getLineNumber', handle.jsProxy);
  }

  /// Fired whenever a change occurs to the document. `changeObj` has a similar
  /// type as the object passed to the editor's "change" event.
  Stream get onChange => onEvent('change', argCount: 2);
}

/// Both `line` and `ch` are 0-based.
///
/// `{line, ch}`
class Position implements Comparable<Position> {
  final int line;
  final int ch;

  Position(this.line, this.ch);

  Position.fromProxy(var obj)
      : line = obj['line'],
        ch = obj['ch'];

  JsObject toProxy() => jsify({'line': line, 'ch': ch});

  operator ==(other) =>
      other is Position && line == other.line && ch == other.ch;

  int get hashCode => (line << 8 | ch).hashCode;

  int compareTo(Position other) {
    if (line == other.line) return ch - other.ch;
    return line - other.line;
  }

  operator <(Position other) => compareTo(other) < 0;

  operator <=(Position other) => compareTo(other) <= 0;

  operator >=(Position other) => compareTo(other) >= 0;

  operator >(Position other) => compareTo(other) > 0;

  String toString() => '[${line}:${ch}]';
}

class ModeInfo extends ProxyHolder {
  factory ModeInfo(JsObject proxy) => proxy == null ? null : ModeInfo._(proxy);

  ModeInfo._(JsObject proxy) : super(proxy);

  /// The mode's human readable, display name.
  String get name => jsProxy['name'];

  String get mime => jsProxy['mime'];

  List<String> get mimes =>
      jsProxy.hasProperty('mimes') ? jsProxy['mimes'] : <String>[mime];

  /// The mode's id.
  String get mode => jsProxy['mode'];

  /// The mode's file extension.
  List<String> get ext => List.from(jsProxy['ext']);

  /// The mode's other file extensions.
  List<String> get alias =>
      jsProxy.hasProperty('alias') ? jsProxy['alias'] : <String>[];
}

/// A source span from a start position ([head]) to an end position ([anchor]);
class Span {
  final Position head;
  final Position anchor;

  Span(this.head, this.anchor);

  Span.fromProxy(var obj)
      : head = Position.fromProxy(obj['head']),
        anchor = Position.fromProxy(obj['anchor']);

  JsObject toProxy() =>
      jsify({'head': head.toProxy(), 'anchor': anchor.toProxy()});

  operator ==(other) =>
      other is Span && head == other.head && anchor == other.anchor;

  int get hashCode => head.hashCode ^ anchor.hashCode;

  String toString() => '${head}=>${anchor}]';
}

/// An object that represents a marker.
class TextMarker extends ProxyHolder {
  TextMarker(JsObject jsProxy) : super(jsProxy);

  /// Removes the mark.
  void clear() => call('clear');

  /// Returns a {from, to} object (both holding document positions), indicating
  /// the current position of the marked range, or `null` if the marker is no
  /// longer in the document. For a bookmark, this list will be length 1.
  List<Position> find() {
    var result = call('find');
    if (result is! JsObject) return null;

    try {
      if (result is Map) {
        return [
          Position.fromProxy(result['from']),
          Position.fromProxy(result['to'])
        ];
      } else {
        return [Position.fromProxy(result)];
      }
    } catch (e) {
      return null;
    }
  }

  /// Return the first (or only) position in this marker / bookmark.
  Position findStart() {
    List<Position> positions = find();
    return (positions == null || positions.isEmpty) ? null : positions.first;
  }

  /// Call if you've done something that might change the size of the marker (for
  /// example changing the content of a replacedWith node), and want to cheaply
  /// update the display.
  void changed() => call('changed');
}

/// See [CodeMirror.addLineWidget].
class LineWidget extends ProxyHolder {
  LineWidget(JsObject jsProxy) : super(jsProxy);

  // TODO: add `line` property

  /// Removes the widget.
  void clear() => call('clear');

  /// Call this if you made some change to the widget's DOM node that might
  /// affect its height. It'll force CodeMirror to update the height of the line
  /// that contains the widget.
  void changed() => call('changed');
}

class LineHandle extends ProxyHolder {
  LineHandle(JsObject jsProxy) : super(jsProxy);

  num get height => jsProxy['height'];

  String get text => jsProxy['text'];
}

class ScrollInfo extends ProxyHolder {
  ScrollInfo(JsObject jsProxy) : super(jsProxy);

  num get left => jsProxy['left'];

  num get top => jsProxy['top'];

  num get width => jsProxy['width'];

  num get height => jsProxy['height'];

  num get clientWidth => jsProxy['clientWidth'];

  num get clientHeight => jsProxy['clientHeight'];
}

class Token {
  /// The character (on the given line) at which the token starts.
  final int start;

  /// The character at which the token ends.
  final int end;

  /// The token's string.
  final String string;

  /// The token type the mode assigned to the token, such as "keyword" or
  /// "comment" (may also be null).
  final String type;

  /// The mode's state at the end of this token.
  final JsObject state;

  Token.fromProxy(var obj)
      : start = obj['start'],
        end = obj['end'],
        string = obj['string'],
        type = obj['type'],
        state = obj['state'];

  String toString() => string;
}

/// A parent class for objects that can hold references to JavaScript objects.
/// It has convenience methods for invoking methods on the JavaScript proxy,
/// a method to add event listeners to the proxy, and a [dispose] method.
/// `dispose` only needs to be called if event listeners were added to an object.
abstract class ProxyHolder {
  final JsObject jsProxy;
  final Map<String, JsEventListener> _events = {};

  ProxyHolder(this.jsProxy);

  dynamic call(String methodName) => jsProxy.callMethod(methodName);

  dynamic callArg(String methodName, var arg) =>
      jsProxy.callMethod(methodName, [arg]);

  dynamic callArgs(String methodName, List args) =>
      jsProxy.callMethod(methodName, args);

  Stream<T> onEvent<T>(String eventName, {int argCount = 1}) {
    if (!_events.containsKey(eventName)) {
      if (argCount == 4) {
        _events[eventName] = JsEventListener<T>(jsProxy, eventName,
            cvtEvent: (a, b, c) => a, argCount: argCount);
      } else if (argCount == 3) {
        _events[eventName] = JsEventListener<T>(jsProxy, eventName,
            cvtEvent: (a, b) => a, argCount: argCount);
      } else if (argCount == 2) {
        _events[eventName] =
            JsEventListener<T>(jsProxy, eventName, argCount: argCount);
      } else {
        _events[eventName] = JsEventListener<T>(jsProxy, eventName);
      }
    }
    return _events[eventName].stream;
  }

  int get hashCode => jsProxy.hashCode;

  operator ==(other) => other is ProxyHolder && jsProxy == other.jsProxy;

  /// This method should be called if any events listeners were added to the
  /// object.
  void dispose() {
    if (_events.isNotEmpty) {
      for (JsEventListener event in _events.values) {
        event.dispose();
      }
    }
  }
}
