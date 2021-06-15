// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

@TestOn('browser')
library codemirror.tests;

import 'dart:html';

import 'package:codemirror/codemirror.dart';
import 'package:test/test.dart';
import 'package:codemirror/searchcursor.dart';

void main() {
  group('searchCursor', createSearchCursorTests);
}

void createSearchCursorTests() {
  late CodeMirror editor;

  setUp(() {
    editor = CodeMirror.fromTextArea(
        querySelector('#textContainer') as TextAreaElement?);
  });

  tearDown(() {
    editor.dispose();
  });

  test('getSearchCursor', () {
    var cursor = SearchCursor.getSearchCursor(editor, 'Lorem');
    print(cursor.pos);
    expect(cursor, isNotNull);
    expect(cursor, isA<SearchCursorContainer>());
  });

  test('findPrevious / findNext', () {
    var cursor = SearchCursor.getSearchCursor(editor, 'ipsum');
    var hasNext = cursor.findNext();
    expect(hasNext, isTrue);

    cursor.findNext();

    var hasPrev = cursor.findPrevious();
    expect(hasPrev, isTrue);
  });

  test('from / to', () {
    var cursor = SearchCursor.getSearchCursor(editor, 'Pellentesque');
    cursor.findNext();

    var from = cursor.from();
    var to = cursor.to();
    expect(from, isNotNull);
    expect(to, isNotNull);
  });

  test('replace', () {
    // TODO(ayshiff) fix failing test
    // var notFoundCursor = SearchCursor.getSearchCursor(editor, 'auctor_replaced');
    // expect(notFoundCursor.findNext(), isFalse);
    //
    // var cursor = SearchCursor.getSearchCursor(editor, 'auctor');
    // cursor.findNext();
    //
    // cursor.replace('auctor_replaced');
    // var foundCursor = SearchCursor.getSearchCursor(editor, 'auctor_replaced');
    // expect(foundCursor.findNext(), isTrue);
  });

  test('atOccurrence', () {
    var cursor = SearchCursor.getSearchCursor(editor, 'dolor');
    cursor.findNext();
    expect(cursor.atOccurrence, isTrue);
  });

  test('doc', () {
    var cursor = SearchCursor.getSearchCursor(editor, 'sapien');
    expect(cursor.doc, isA<Doc>());
  });

  test('pos', () {
    var cursor = SearchCursor.getSearchCursor(editor, 'ipsum');
    expect(cursor.pos, isA<Position>());
  });
}
