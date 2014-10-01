// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:grinder/grinder.dart';

void main([List<String> args]) {
  task('init', init);
  task('copy-codemirror', copyCodeMirror, ['init']);
  task('clean', clean);

  startGrinder(args);
}

/**
 * Do any necessary build set up.
 */
void init(GrinderContext context) {
  // Verify we're running in the project root.
  if (!getDir('lib').existsSync() || !getFile('pubspec.yaml').existsSync()) {
    context.fail('This script must be run from the project root.');
  }
}

/**
 * Concatenate the template files into data files that the generators can
 * consume.
 */
void copyCodeMirror(GrinderContext context) {
  final Directory SRC_DIR = new Directory('third_party/codemirror');
  final Directory DEST_DIR = new Directory('lib');

  // Copy codemirror.js.
  copyFile(joinFile(SRC_DIR, ['codemirror.js']), DEST_DIR, context);

  // Copy codemirror.css.
  copyFile(joinFile(SRC_DIR, ['lib', 'codemirror.css']),
      joinDir(DEST_DIR, ['css']), context);

  // Copy the themes.
  copyDirectory(joinDir(SRC_DIR, ['theme']), joinDir(DEST_DIR, ['theme']),
      context);
}

/**
 * Delete all generated artifacts.
 */
void clean(GrinderContext context) {

}
