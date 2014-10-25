// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:grinder/grinder.dart';

final Directory srcDir = new Directory('third_party/codemirror');
final Directory destDir = new Directory('lib');

void main([List<String> args]) {
  task('init', init);
  task('copy-codemirror', copyCodeMirror, ['init']);
  task('test', test, ['copy-codemirror']);
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
  // Copy codemirror.js.
  String jsSource = _concatenateModes(srcDir);
  joinFile(destDir, ['codemirror.js']).writeAsStringSync(jsSource);
  //copyFile(joinFile(srcDir, ['lib', 'codemirror.js']), destDir, context);

  // Copy codemirror.css.
  copyFile(joinFile(srcDir, ['lib', 'codemirror.css']),
      joinDir(destDir, ['css']), context);

  // Copy the themes.
  copyDirectory(joinDir(srcDir, ['theme']), joinDir(destDir, ['theme']),
      context);
}

/**
 * Run the tests.
 */
void test(GrinderContext context) {
  // TODO(devoncarew): Run browser tests.
  //Tests.runCliTests(context);
}

/**
 * Delete all generated artifacts.
 */
void clean(GrinderContext context) {
  deleteEntity(joinFile(destDir, ['codemirror.js']), context);
  deleteEntity(joinFile(destDir, ['css', 'codemirror.css']), context);
  deleteEntity(joinFile(destDir, ['theme']), context);
}

String _concatenateModes(Directory dir) {
  List files = [];

  // Read lib/codemirror.js.
  files.add(joinFile(dir, ['lib', 'codemirror.js']));

  // Read mode/meta.js.
  files.add(joinFile(dir, ['mode', 'meta.js']));

  // Read all the mode files.
  var modeFiles = joinDir(dir, ['mode'])
    .listSync()
    .where((dir) => dir is Directory)
    .map((dir) => joinFile(dir, ['${fileName(dir)}.js']))
    .where((f) => f.existsSync());
  files.addAll(modeFiles);

  return files.map((File file) {
    String header = "// ${fileName(file)}\n\n";
    return header + file.readAsStringSync().trim() + "\n";
  }).join("\n");
}
