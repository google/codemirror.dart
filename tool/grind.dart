// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:grinder/grinder.dart';

final Directory srcDir = new Directory('third_party/codemirror');
final Directory destDir = new Directory('lib');

void main([List<String> args]) {
  task('init', init);
  task('install', install, ['init']);
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
 * Update / install a new version of the codemirror library.
 */
void install(GrinderContext context) {
  runProcess(context, 'bower', arguments: ['install']);
}

/**
 * Copy the codemirror files from third_party/ into lib/.
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

  // Copy the addons.
  copyDirectory(joinDir(srcDir, ['addon']), joinDir(destDir, ['addon']),
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

  // Read addon/mode/simple.js - required by some modes.
  files.add(joinFile(dir, ['addon', 'mode', 'simple.js']));

  // Add some likely addons.
  files.add(joinFile(dir, ['addon', 'edit', 'closebrackets.js']));
  files.add(joinFile(dir, ['addon', 'edit', 'matchbrackets.js']));

  files.add(joinFile(dir, ['addon', 'hint', 'show-hint.js']));
  files.add(joinFile(dir, ['addon', 'hint', 'css-hint.js']));
  files.add(joinFile(dir, ['addon', 'hint', 'html-hint.js']));

  files.add(joinFile(dir, ['addon', 'lint', 'lint.js']));
  files.add(joinFile(dir, ['addon', 'lint', 'css-lint.js']));

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
