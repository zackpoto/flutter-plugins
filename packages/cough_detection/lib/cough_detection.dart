import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';
import 'dart:math';

const String EVENT_CHANNEL_NAME = 'cough_detection.eventChannel';

/** A [CoughDetector] analyzes audio data.**/
class CoughDetector {
  List<dynamic> _audioData;

  CoughDetector(this._audioData);

  List<dynamic> get audioData => _audioData;
}

/** A [AudioStreamer] object is reponsible for connecting
 * to the native environment and streaming audio from the microphone.**/

class AudioStreamer {
  static const EventChannel _noiseEventChannel =
      EventChannel(EVENT_CHANNEL_NAME);

  Stream<List<dynamic>> _noiseStream;

  Stream<List<dynamic>> get noiseStream {
    if (_noiseStream == null) {
      _noiseStream = _noiseEventChannel.receiveBroadcastStream().map((buffer) => buffer as List<dynamic>);
    }
    return _noiseStream;
  }
}
