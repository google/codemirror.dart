// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/**
 * Utility methods and classes for working with JS interop.
 */
library codemirror.js_utils;

import 'dart:async';
import 'dart:convert';
import 'dart:js';

final JsObject _jsJSON = context['JSON'];
final JsObject _Object = context['Object'];

/**
 * Convert a Dart object to a suitable parameter to a JavaScript method.
 */
JsObject jsify(object) => new JsObject.jsify(object);

/**
 * Convert a JavaScript result object to an equivalent Dart map.
 */
Map mapify(JsObject obj) {
  if (obj == null) return null;
  return JSON.decode(_jsJSON.callMethod('stringify', [obj]));
}

/**
 * Return the object keys of a JavaScript object.
 */
List keys(JsObject obj) => _Object.callMethod('keys', [obj]);

/**
 * Add an event listener to CodeMirror objects. This uses CodeMirror's `on`
 * and `off` convention. It can listen for events that result in one or two
 * event parameters, and can optionally convert the event object into a
 * different object.
 */
class JsEventListener {
  final JsObject _proxy;
  final String _name;
  final Function cvtEvent;
  final bool twoArgs;

  StreamController _controller;
  JsFunction _callback;

  JsEventListener(this._proxy, this._name, {this.cvtEvent, this.twoArgs: false});

  Stream get stream {
    if (_controller == null) {
      _controller = new StreamController.broadcast(
        onListen: () {
          if (twoArgs) {
            _callback = _proxy.callMethod('on', [_name, (obj, e) {
              _controller.add(cvtEvent == null ? null : cvtEvent(e));
            }]);
          } else {
            _callback = _proxy.callMethod('on', [_name, (obj) {
              _controller.add(cvtEvent == null ? null : cvtEvent(obj));
            }]);
          }
        },
        onCancel: () {
          _proxy.callMethod('off', [_name, _callback]);
          _callback = null;
        }
      );
    }
    return _controller.stream;
  }

  Future dispose() {
    if (_controller == null) return new Future.value();
    return _controller.close();
  }
}
