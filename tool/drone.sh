#!/bin/bash

# Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Start a virtual frame buffer.
if [ "$DRONE" = "true" ]; then
  sudo start xvfb
fi

# Display installed versions.
dart --version

# Get our packages.
pub get

# Copy codemirror from third_party.
./grind build

# Verify that the libraries are error free.
dartanalyzer --package-root packages/ --fatal-warnings \
  example/simple.dart \
  lib/codemirror.dart \
  test/all.dart

# Run the tests.
#dart test/all.dart
