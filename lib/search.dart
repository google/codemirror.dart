// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/**
 * A wrapper around the `addon/search/searchcursor.js` addon.
 */
library codemirror.search;

import 'dart:js';

import 'codemirror.dart';

class Search {
  /**
   * A search method which can be used to implement search / replace
   * functionality. [query] can be a regular expression or a string (only
   * strings will match across lines — if they contain newlines). [start]
   * provides the starting position of the search. If left off it defaults to
   * the start of the document. [caseFold] is only relevant when matching a
   * string. It will cause the search to be case-insensitive.
   */
  static Cursor getSearchCursor(CodeMirror editor, String query,
      [Position start, bool caseFold]) {
    List args = [query];

    if (start != null) {
      args.add(start);
      if (caseFold != null) args.add(caseFold);
    }

    return new Cursor.fromProxy(editor.callArgs('getSearchCursor', args));
  }
}

class Cursor extends ProxyHolder {
  Cursor.fromProxy(JsObject jsProxy) : super(jsProxy);

  bool findNext() => call('findNext');

  /**
   * Search forward or backward from the current position. The return value
   * indicates whether a match was found. If matching a regular expression, the
   * return value will be the array returned by the match method, in case you
   * want to extract matched groups.
   */
  bool findPrevious() => call('findPrevious');

  Position from() => new Position.fromProxy(call('from'));

  /**
   * These are only valid when the last call to findNext or findPrevious did not
   * return false. They will return [Position] objects pointing at the start and
   * end of the match.
   */
  Position to() => new Position.fromProxy(call('to'));

  /**
   * Replaces the currently found match with the given text and adjusts the
   * cursor position to reflect the replacement.
   */
  void replace(String text) => callArg('replace', text);
}
