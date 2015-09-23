#!/bin/bash

# Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Copy codemirror from third_party.
dart tool/grind.dart build

# Verify that the libraries are error free.
pub global activate tuneup
pub global run tuneup check

# And that DDC is happy with it.
pub global activate dev_compiler
pub global run dev_compiler lib/codemirror.dart
pub global run dev_compiler lib/hints.dart

# Run the tests.
#dart test/all.dart
