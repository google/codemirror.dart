// Copyright (c) 2021, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/// A wrapper around the `addon/search/searchcursor.js` addon.
library codemirror.searchcursor;

import 'dart:js';

import 'src/js_utils.dart';
import 'codemirror.dart';

class SearchCursor {
  /// Retrieve the search cursor from the editor instance.
  static SearchCursorContainer getSearchCursor(CodeMirror editor, String value,
      {Position? start, Map? options}) {
    if (options == null) {
      return SearchCursorContainer._(
          editor.callArgs('getSearchCursor', [value, start]));
    } else {
      return SearchCursorContainer._(
          editor.callArgs('getSearchCursor', [value, start, jsify(options)]));
    }
  }
}

class SearchCursorContainer extends ProxyHolder {
  SearchCursorContainer._(JsObject? jsProxy) : super(jsProxy);

  bool get atOccurrence => jsProxy!['atOccurrence'];
  Doc get doc => Doc.fromProxy(jsProxy!['doc']);
  Position get pos => Position.fromProxy(jsProxy!['pos']);

  /// Search forward from the current position
  bool findNext() => call('findNext');

  /// Search backward from the current position
  bool findPrevious() => call('findPrevious');
  Position from() => Position.fromProxy(call('from'));
  Position to() => Position.fromProxy(call('to'));
  String replace(String text, {dynamic origin}) {
    if (origin == null) {
      return callArg('replace', text);
    } else {
      return callArgs('replace', [text, origin]);
    }
  }
}
