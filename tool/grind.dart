// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:grinder/grinder.dart';

final String cm_minified_dirname = 'codemirror_minified';
final Directory srcMinifiedDir =
    joinDir(Directory('third_party'), [cm_minified_dirname]);
Directory srcDir = Directory('third_party/codemirror');
final Directory destDir = Directory('lib');

Future main(List<String> args) => grind(args);

@Task(
    'Minify the codemirror files, and then proceed with "build" using minified codemirror\n--verbose shows intermediate output')
@Depends(clean_minified)
void build_minified() {
  TaskArgs args = context.invocation.arguments;
  bool verbose = args.getFlag('verbose');
  RunOptions runOpts = RunOptions(
      workingDirectory: 'third_party', includeParentEnvironment: true);
  // make sure google closure compiler is there
  run('npm', arguments: ['install'], quiet: !verbose, runOptions: runOpts);

  // run the gulpfile.js and minify codemirror into codemirror_minified
  run('gulp', quiet: !verbose, runOptions: runOpts);

  // OK we can go ahead and build like normal, but using the minified source
  srcDir = srcMinifiedDir;
  build();
}

@Task('Copy the codemirror files from third_party/ into lib/')
void build() {
  // Copy codemirror.js.
  var jsSource = _concatenateModesAndOtherDependencies(srcDir);
  joinFile(destDir, ['codemirror.js']).writeAsStringSync(jsSource);
  //copy(joinFile(srcDir, ['lib', 'codemirror.js']), destDir);

  // Copy codemirror.css.
  copy(joinFile(srcDir, ['lib', 'codemirror.css']), joinDir(destDir, ['css']));

  // Copy the addons.
  copy(joinDir(srcDir, ['addon']), joinDir(destDir, ['addon']));

  // Copy the keymaps.
  copy(joinDir(srcDir, ['keymap']), joinDir(destDir, ['keymap']));

  // Copy the modes.
  copy(joinDir(srcDir, ['mode']), joinDir(destDir, ['mode']));

  // Copy the themes.
  copy(joinDir(srcDir, ['theme']), joinDir(destDir, ['theme']));
}

@Task('Run the tests')
void test() {
  run('pub', arguments: ['run', 'test:test', '--platform=chrome']);
}

@Task('Delete all generated artifacts')
void clean() {
  delete(joinFile(destDir, ['codemirror.js']));
  delete(joinFile(destDir, ['css', 'codemirror.css']));
  delete(joinDir(destDir, ['addon']));
  delete(joinDir(destDir, ['keymap']));
  delete(joinDir(destDir, ['mode']));
  delete(joinDir(destDir, ['theme']));
}

@Task('Delete all generated minified codemirror')
void clean_minified() {
  delete(srcMinifiedDir);
}

@Task('Delete all node modules used by minifier,build_minified will reinstall')
void clean_node() {
  final Directory thirdPartyDir = Directory('third_party');
  delete(joinDir(thirdPartyDir, ['node_modules']));
  delete(joinFile(thirdPartyDir, ['package-lock.json']));
}

String _concatenateModesAndOtherDependencies(Directory dir) {
  TaskArgs args = context.invocation.arguments;
  bool legacyAddons = args.getFlag('legacyaddons');

  var files = <File>[];

  // Read lib/codemirror.js.
  files.add(joinFile(dir, ['lib', 'codemirror.js']));

  // Add some likely addons.
  files.add(joinFile(dir, ['addon', 'comment', 'comment.js']));
  files.add(joinFile(dir, ['addon', 'comment', 'continuecomment.js']));

  files.add(joinFile(dir, ['addon', 'edit', 'closebrackets.js']));
  files.add(joinFile(dir, ['addon', 'edit', 'matchbrackets.js']));
  files.add(joinFile(dir, ['addon', 'edit', 'closetag.js']));

  files.add(joinFile(dir, ['addon', 'hint', 'show-hint.js']));
  files.add(joinFile(dir, ['addon', 'hint', 'css-hint.js']));
  files.add(joinFile(dir, ['addon', 'hint', 'html-hint.js']));
  files.add(joinFile(dir, ['addon', 'hint', 'xml-hint.js']));

  files.add(joinFile(dir, ['addon', 'lint', 'lint.js']));
  files.add(joinFile(dir, ['addon', 'lint', 'css-lint.js']));

  // Add an API to add a panel above or below the editor.
  files.add(joinFile(dir, ['addon', 'display', 'panel.js']));

  // Add search addons.
  files.add(joinFile(dir, ['addon', 'search', 'search.js']));
  files.add(joinFile(dir, ['addon', 'search', 'searchcursor.js']));

  if (!legacyAddons) {
    // used on all dart-pads
    files.add(joinFile(dir, ['addon', 'scroll', 'simplescrollbars.js']));

    // search dialog
    files.add(joinFile(dir, ['addon', 'scroll', 'annotatescrollbar.js']));
    files.add(joinFile(dir, ['addon', 'search', 'matchesonscrollbar.js']));
    files.add(joinFile(dir, ['addon', 'search', 'match-highlighter.js']));
    // code folding
    files.add(joinFile(dir, ['addon', 'fold', 'foldcode.js']));
    files.add(joinFile(dir, ['addon', 'fold', 'foldgutter.js']));
    files.add(joinFile(dir, ['addon', 'fold', 'brace-fold.js']));
    files.add(joinFile(dir, ['addon', 'fold', 'xml-fold.js']));
    files.add(joinFile(dir, ['addon', 'fold', 'indent-fold.js']));
    files.add(joinFile(dir, ['addon', 'fold', 'comment-fold.js']));
    // html tag matching
    files.add(joinFile(dir, ['addon', 'edit', 'matchtags.js']));
  }

  // Required by some modes.
  files.add(joinFile(dir, ['addon', 'mode', 'overlay.js']));
  files.add(joinFile(dir, ['addon', 'mode', 'simple.js']));

  // Read mode/meta.js.
  files.add(joinFile(dir, ['mode', 'meta.js']));

  // Read in selected mode files.
  files.add(joinFile(dir, ['mode', 'clike', 'clike.js']));
  files.add(joinFile(dir, ['mode', 'css', 'css.js']));
  files.add(joinFile(dir, ['mode', 'dart', 'dart.js']));
  files.add(joinFile(dir, ['mode', 'htmlmixed', 'htmlmixed.js']));
  files.add(joinFile(dir, ['mode', 'javascript', 'javascript.js']));
  files.add(joinFile(dir, ['mode', 'markdown', 'markdown.js']));
  files.add(joinFile(dir, ['mode', 'properties', 'properties.js']));
  files.add(joinFile(dir, ['mode', 'shell', 'shell.js']));
  files.add(joinFile(dir, ['mode', 'xml', 'xml.js']));
  files.add(joinFile(dir, ['mode', 'yaml', 'yaml.js']));

  // Read things we need for vim keymap
  files.add(joinFile(dir, ['addon', 'dialog', 'dialog.js']));
  files.add(joinFile(dir, ['keymap', 'vim.js']));

//  var modeFiles = joinDir(dir, ['mode'])
//    .listSync()
//    .where((dir) => dir is Directory)
//    .map((dir) => joinFile(dir, ['${fileName(dir)}.js']))
//    .where((f) => f.existsSync());
//  files.addAll(modeFiles);
  int count = 0;
  String topHeaderFileList = files.map((File file) {
    String filenameCommentForHeader;
    if (count++ == 0) {
      // codemirror file
      filenameCommentForHeader = '// ${fileName(file)}';
    } else {
      // addons
      List<String> fileparts = file.path.split('/');
      int len = fileparts.length;
      filenameCommentForHeader = '//    ' +
          (len >= 3 && (fileparts[len - 3] != cm_minified_dirname)
              ? fileparts[len - 3] + '/'
              : '') +
          (len >= 2 ? fileparts[len - 2] + '/' : '') +
          fileparts[len - 1];
    }
    return filenameCommentForHeader;
  }).join('\n');

  return '$topHeaderFileList\n\n' +
      files.map((File file) {
        var header = '// ${fileName(file)}\n\n';
        return header + file.readAsStringSync().trim() + '\n';
      }).join('\n');
}
