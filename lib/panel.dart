// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/**
 * A wrapper around the `addon/display/panel.js` addon.
 */
library codemirror.panel;

import 'dart:html';
import 'dart:js';

import 'codemirror.dart';
import 'src/js_utils.dart';

class Panel {
  /**
   * Places a DOM node above or below an editor, and shrinks the editor to make
   * room for the node. The method takes as first argument as DOM node, and as
   * second an optional options object. By default, the panel ends up above the
   * editor.
   */
  static PanelContainer addPanel(CodeMirror editor, Element element,
      {bool below}) {
    if (below != null && below) {
      Map options = {'position': 'bottom'};
      return new PanelContainer._(
          editor.callArgs('addPanel', [element, jsify(options)]));
    } else {
      return new PanelContainer._(editor.callArg('addPanel', element));
    }
  }
}

class PanelContainer extends ProxyHolder {
  PanelContainer._(JsObject jsProxy) : super(jsProxy);

  /**
   * Used to remove the panel.
   */
  void clear() => call('clear');

  /**
   * Used to notify the addon when the size of the panel's DOM node has changed.
   */
  void changed() => call('changed');
}
