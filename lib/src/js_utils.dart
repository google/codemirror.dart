// Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

/// Utility methods and classes for working with JS interop.
library codemirror.js_utils;

import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:js';

final JsObject _jsJSON = context['JSON'];
final JsObject _Object = context['Object'];

/// Convert a Dart object to a suitable parameter to a JavaScript method.
JsObject jsify(object) => JsObject.jsify(object);

/// Convert a JavaScript result object to an equivalent Dart map.
Map mapify(JsObject obj) {
  if (obj == null) return null;
  return jsonDecode(_jsJSON.callMethod('stringify', [obj]));
}

/// Return the object keys of a JavaScript object.
List keys(JsObject obj) => _Object.callMethod('keys', [obj]);

/// Add an event listener to CodeMirror objects. This uses CodeMirror's `on`
/// and `off` convention. It can listen for events that result in one or two
/// event parameters, and can optionally convert the event object into a
/// different object.
class JsEventListener<T> {
  final JsObject _proxy;
  final String _name;
  final Function cvtEvent;
  final int argCount;

  StreamController<T> _controller;
  JsFunction _callback;

  JsEventListener(
    this._proxy,
    this._name, {
    this.cvtEvent,
    this.argCount = 1,
  });

  Stream<T> get stream {
    if (_controller == null) {
      _controller = StreamController.broadcast(
          onListen: () {
            if (argCount == 4) {
              _callback = _proxy.callMethod('on', [
                _name,
                (obj, a, b, c) {
                  _controller.add(cvtEvent == null ? a : cvtEvent(a, b, c));
                }
              ]);
            } else if (argCount == 3) {
              _callback = _proxy.callMethod('on', [
                _name,
                (obj, a, b) {
                  _controller.add(cvtEvent == null ? a : cvtEvent(a, b));
                }
              ]);
            } else if (argCount == 2) {
              _callback = _proxy.callMethod('on', [
                _name,
                (obj, a) {
                  _controller.add(cvtEvent == null ? a : cvtEvent(a));
                }
              ]);
            } else {
              _callback = _proxy.callMethod('on', [
                _name,
                (obj) {
                  _controller.add(cvtEvent == null ? null : cvtEvent(obj));
                }
              ]);
            }
          },
          onCancel: () {
            _proxy.callMethod('off', [_name, _callback]);
            _callback = null;
          },
          sync: true);
    }
    return _controller.stream;
  }

  Future dispose() {
    if (_controller == null) return Future.value();
    return _controller.close();
  }
}
