/**
 * @license
 * The MIT License
 *
 * Copyright (c) 2016 Michael Zhou
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */

/**
 * @fileoverview Minification process for CodeMirror.
 * @author zhoumotongxue008@gmail.com (Michael Zhou)
 * 
 * This file was orginally part of https://github.com/Dominator008/CodeMirror-minified
 * and has been repurposed to minify the codemirror source for codemirror.dart
 */

'use strict';

const {series, parallel, src, dest} = require('gulp');
const flatmap = require('gulp-flatmap');
const closureCompiler = require('google-closure-compiler').gulp();
const cleanCss = require('gulp-clean-css');

const CM_ROOT = 'codemirror/';
const CM_MINIFIED_ROOT = 'codemirror_minified/';

function runFlatMap() {
  return flatmap((stream, file) => {
    const pathAtCmRoot = file.relative.replace(CM_ROOT, '');
    // Travis kills a build if no log output for 10 minutes
    console.log('Minifying ' + pathAtCmRoot);
    return stream.pipe(closureCompiler({
      compilation_level: 'SIMPLE',
      language_in: 'STABLE',
      language_out: 'ECMASCRIPT5_STRICT',
      js_output_file: pathAtCmRoot,
      warning_level: 'QUIET'
    }));
  });
}

function minifyMainJs() {
  return src(
             [
               CM_ROOT + 'addon/**/*.js',
               CM_ROOT + 'keymap/**/*.js',
               CM_ROOT + 'lib/**/*.js',
             ],
             {base: '.'})
      .pipe(runFlatMap())
      .pipe(dest(CM_MINIFIED_ROOT));
}

function minifyModesJs() {
  return src([CM_ROOT + 'mode/**/*.js', '!' + CM_ROOT + 'mode/**/*test.js'],
             {base: '.'})
      .pipe(runFlatMap())
      .pipe(dest(CM_MINIFIED_ROOT));
}

function minifyCss() {
  return src(
             [
               CM_ROOT + 'addon/**/*.css', CM_ROOT + 'lib/**/*.css',
               CM_ROOT + 'mode/**/*.css', CM_ROOT + 'theme/**/*.css'
             ],
             {base: CM_ROOT})
      .pipe(cleanCss())
      .pipe(dest(CM_MINIFIED_ROOT));
}

function copyTextFiles() {
  return src([CM_ROOT + 'AUTHORS', CM_ROOT + 'CHANGELOG.md'], {base: CM_ROOT})
      .pipe(dest(CM_MINIFIED_ROOT));
}

exports.minify = parallel(minifyMainJs, minifyModesJs, minifyCss);
exports.default = series(copyTextFiles, exports.minify);