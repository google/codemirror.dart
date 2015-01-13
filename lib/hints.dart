// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/**
 * A wrapper around the `hint/show-hint.js` addon.
 */
library codemirror.hints;

import 'dart:async';
import 'dart:js';

import 'codemirror.dart';
import 'src/js_utils.dart';

typedef HintResults HintsHelper(CodeMirror editor, [HintsOptions options]);
typedef Future<HintResults> HintsHelperAsync(CodeMirror editor, [HintsOptions options]);

class Hints {
  static void registerHintsHelper(String mode, HintsHelper helper) {
    CodeMirror.registerHelper('hint', mode, (editor, options) {
      HintResults results = helper(
          new CodeMirror.fromJsObject(editor), new HintsOptions(options));
      return results == null ? null : results.toProxy();
    });
  }

  static void registerHintsHelperAsync(String mode, HintsHelperAsync helper) {
    JsFunction function = new JsFunction.withThis((callback, editor, [options]) {
      print(callback);
      print(editor);
      print(options);
      Future<HintResults> results = helper(
          new CodeMirror.fromJsObject(editor), new HintsOptions.fromProxy(options));
      results.then((r) {
        (callback[0] as JsFunction).apply([results == null ? null : r.toProxy()]);
        //callback(results == null ? null : r.toProxy());
      });
    });

    function['async'] = true;

    CodeMirror.registerHelper('hint', mode, function);
  }
}

/**
 * The plugin understands the following options (the options object will also be
 * passed along to the hinting function, which may understand additional
 * options).
 */
class HintsOptions extends ProxyHolder {
  HintsOptions(JsObject jsProxy) : super(jsProxy);

  factory HintsOptions.fromProxy(JsObject jsProxy) {
    return jsProxy == null ? null : new HintsOptions(jsProxy);
  }

  /**
   * Determines whether, when only a single completion is available, it is
   * completed without showing the dialog. Defaults to true.
   */
  bool get completeSingle => _boolOption('completeSingle', true);

  /**
   * Whether the pop-up should be horizontally aligned with the start of the
   * word (true, default), or with the cursor (false).
   */
  bool get alignWithWord => _boolOption('alignWithWord', true);

  /**
   * When enabled (which is the default), the pop-up will close when the editor
   * is unfocused.
   */
  bool get closeOnUnfocus => _boolOption('closeOnUnfocus', true);

  dynamic getOption(String name) => jsProxy[name];

  bool _boolOption(String name, bool defaultValue) {
    bool val = jsProxy[name];
    return val != null ? val : defaultValue;
  }
}

class HintResults {
  final List<String> _strResults;
  final List<HintResult> _hintResults;

  final Position from;
  final Position to;

  HintResults.fromStrings(List<String> results, this.from, this.to) :
    this._strResults = results, this._hintResults = null;

  HintResults.fromHints(List<HintResult> results, this.from, this.to) :
    this._strResults = null, this._hintResults = results;

  JsObject toProxy() {
    if (_strResults != null) {
      return jsify({
        'list': _strResults,
        'from': from.toProxy(),
        'to': to.toProxy()
      });
    } else {
      return jsify({
        'list': _hintResults.map((r) => r.toProxy()).toList(),
        'from': from.toProxy(),
        'to': to.toProxy()
      });
    }
  }
}

// TODO: finish
class HintResult {
  final String text;

  HintResult(this.text);

  JsObject toProxy() {
    Map m = {'text': text};

    return jsify(m);
  }
}
