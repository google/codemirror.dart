// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/// A wrapper around the `hint/show-hint.js` addon.
library codemirror.hints;

import 'dart:async';
import 'dart:html' show Element;
import 'dart:js';

import 'codemirror.dart';
import 'src/js_utils.dart';

typedef HintsHelper = HintResults Function(CodeMirror editor,
    [HintsOptions options]);

typedef HintsHelperAsync = Future<HintResults> Function(CodeMirror editor,
    [HintsOptions options]);

typedef HintsResultsSelectCallback = void Function(
    HintResult completion, Element element);

typedef HintsResultsPickCallback = void Function(HintResult completion);

/// To use codemirror hints (aka code completion), register either a synchronous
/// or aynchronous hints helper for a given mode (see [Hints.registerHintsHelper]
/// and [Hints.registerHintsHelperAsync]). The second helper type returns a
/// `Future` with the completion results.
///
/// In addition, you need to tie the `autocomplete` command to a key-binding.
/// When creating a CodeMirror instance, pass
/// `'extraKeys': { 'Ctrl-Space': 'autocomplete' }` into the options object.
/// Then, include the hints css in your entrypoint html file:
/// `<link href="packages/codemirror/addon/hint/show-hint.css" rel="stylesheet">`.
///
/// See the CodeMirror
/// [sample](https://github.com/google/codemirror.dart/tree/master/example) for a
/// working example of using the hints API.
class Hints {
  static bool _inited = false;

  static JsObject get _cm => context['CodeMirror'];

  static void _init() {
    if (_inited) return;
    _inited = true;

    _cm['showHint'] = JsFunction.withThis(_showHint);
    _cm['commands']['autocomplete'] = _cm['showHint'];
  }

  static void registerHintsHelper(String mode, HintsHelper helper) {
    _init();

    CodeMirror.registerHelper('hint', mode, (editor, options) {
      HintResults results =
          helper(CodeMirror.fromJsObject(editor), HintsOptions(options));
      return results == null ? null : results.toProxy();
    });
  }

  static void registerHintsHelperAsync(String mode, HintsHelperAsync helper) {
    _init();

    JsFunction function =
        JsFunction.withThis((win, editor, showHints, [options]) {
      Future<HintResults> results = helper(
          CodeMirror.fromJsObject(editor), HintsOptions.fromProxy(options));

      results.then((HintResults r) {
        showHints.apply([results == null ? null : r.toProxy()]);
      });
    });

    function['async'] = true;

    CodeMirror.registerHelper('hint', mode, function);
  }

  static void _showHint(var myThis, var editor, [var hintsFunc, var opt]) {
    var pos = editor.callMethod('getCursor');
    JsObject helper = editor.callMethod('getHelper', [pos, 'hint']);

    if (helper == null) {
      helper = _cm['hint']['auto'];
    }

    Map options = {'hint': helper};
    if (opt != null) {
      options.addAll(opt);
    }

    return editor.callMethod('showHint', [jsify(options)]);
  }
}

/// The plugin understands the following options (the options object will also be
/// passed along to the hinting function, which may understand additional
/// options).
class HintsOptions extends ProxyHolder {
  HintsOptions(JsObject jsProxy) : super(jsProxy);

  factory HintsOptions.fromProxy(JsObject jsProxy) {
    return jsProxy == null ? null : HintsOptions(jsProxy);
  }

  /// Determines whether, when only a single completion is available, it is
  /// completed without showing the dialog. Defaults to true.

  bool get completeSingle => _boolOption('completeSingle', true);

  /// Whether the pop-up should be horizontally aligned with the start of the
  /// word (true, default), or with the cursor (false).

  bool get alignWithWord => _boolOption('alignWithWord', true);

  /// When enabled (which is the default), the pop-up will close when the editor
  /// is unfocused.

  bool get closeOnUnfocus => _boolOption('closeOnUnfocus', true);

  dynamic getOption(String name) => jsProxy[name];

  bool _boolOption(String name, bool defaultValue) {
    bool val = jsProxy[name];
    return val != null ? val : defaultValue;
  }
}

/// The return value from a hints (code completion) operation.
class HintResults {
  final List _results;
  final Position from;
  final Position to;

  JsObject _obj;

  HintResults.fromStrings(List<String> results, this.from, this.to)
      : this._results = results;

  HintResults.fromHints(List<HintResult> results, this.from, this.to)
      : this._results = results;

  /// The list of code completion results. This list is either a list of
  /// strings or a list of [HintResult]s.
  List get results => _results;

  /// Fired when the pop-up is shown.
  void registerOnShown(Function onShown) {
    Hints._cm.callMethod("on", [toProxy(), "shown", onShown]);
  }

  /// Fired when a completion is selected. Passed the completion value and the
  /// DOM node that represents it in the menu.
  ///
  /// The completion [HintResult] is not guaranteed to be the same object
  /// instance as the one provided by the `HintResults`.
  void registerOnSelect(HintsResultsSelectCallback onSelect) {
    Hints._cm.callMethod("on", [
      toProxy(),
      "select",
      (completion, element) {
        if (completion is String) {
          onSelect(HintResult(completion), element);
        } else {
          onSelect(HintResult.fromProxy(completion), element);
        }
      }
    ]);
  }

  /// Fired when a completion is picked. Passed the completion value.
  ///
  /// The completion [HintResult] is not guaranteed to be the same object
  /// instance as the one provided by the `HintResults`.
  void registerOnPick(HintsResultsPickCallback onPick) {
    Hints._cm.callMethod("on", [
      toProxy(),
      "pick",
      (completion) {
        if (completion is String) {
          onPick(HintResult(completion));
        } else {
          onPick(HintResult.fromProxy(completion));
        }
      }
    ]);
  }

  /// Fired when the completion is finished.
  void registerOnClose(Function onShown) {
    Hints._cm.callMethod("on", [toProxy(), "close", onShown]);
  }

  void registerOnUpdate(Function onUpdate) {
    Hints._cm.callMethod("on", [toProxy(), "update", onUpdate]);
  }

  JsObject toProxy() {
    if (_obj == null) {
      _obj = jsify({
        'list': _results.map((r) => r is HintResult ? r.toProxy() : r).toList(),
        'from': from.toProxy(),
        'to': to.toProxy()
      });
    }

    return _obj;
  }
}

typedef HintRenderer = Function(Element element, HintResult hint);

typedef HintApplier = Function(
    CodeMirror editor, HintResult hint, Position from, Position to);

class HintResult {
  /// The completion text. This is the only required property.
  final String text;

  /// The text that should be displayed in the menu.
  final String displayText;

  /// A CSS class name to apply to the completion's line in the menu.
  final String className;

  /// Optional from position that will be used by pick() instead of the global
  /// one passed with the full list of completions.
  final Position from;

  /// Optional to position that will be used by pick() instead of the global one
  /// passed with the full list of completions.
  final Position to;

  /// A method used to create the DOM structure for showing the completion by
  /// appending it to its first argument. This cooresponds to the JS codemirror
  /// `render` function.
  final HintRenderer hintRenderer;

  /// A method used to actually apply the completion, instead of the default
  /// behavior. This cooresponds to the JS codemirror `hint` function.
  final HintApplier hintApplier;

  HintResult(this.text,
      {this.displayText,
      this.className,
      this.from,
      this.to,
      this.hintRenderer,
      this.hintApplier});

  HintResult.fromProxy(JsObject m)
      : text = m['text'],
        displayText = m['displayText'],
        className = m['className'],
        from = _createPos(m['from']),
        to = _createPos(m['to']),
        hintRenderer = null,
        hintApplier = null;

  JsObject toProxy() {
    Map m = {'text': text};
    if (displayText != null) m['displayText'] = displayText;
    if (className != null) m['className'] = className;
    if (from != null) m['from'] = from.toProxy();
    if (to != null) m['to'] = to.toProxy();

    if (hintApplier != null) {
      m['hint'] = (cm, data, completion) {
        Position from = _createPos(data['from']);
        Position to = _createPos(data['to']);
        hintApplier(CodeMirror.fromJsObject(cm), this, from, to);
      };
    }

    if (hintRenderer != null) {
      m['render'] = (element, data, completion) {
        hintRenderer(element, this);
      };
    }

    return jsify(m);
  }

  String toString() => '[${text}]';

  static Position _createPos(JsObject obj) {
    return obj == null ? null : Position.fromProxy(obj);
  }
}
