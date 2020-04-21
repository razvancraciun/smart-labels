


import 'dart:typed_data';

import 'package:flutter/services.dart';

class TfliteClient {

    MethodChannel _methodChannel = const MethodChannel('tflite/interpreter');

    void init() async {
        await _methodChannel.invokeMethod('init');
    }

    void run(List<Uint8List> bytes) async {
       var objects = await _methodChannel.invokeMethod('run', bytes);
    }

}