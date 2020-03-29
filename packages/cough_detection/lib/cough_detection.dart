import 'dart:async';
import 'dart:core';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

const String EVENT_CHANNEL_NAME = 'cough_detection.eventChannel';

/** A [CoughDetector] analyzes audio data.**/
class CoughDetector {
  List<dynamic> _data;

  CoughDetector(this._data);

  List<dynamic> get data => _data;

  void detectStuff() {
    ////  process data
  }
}

/** A [AudioStreamer] object is reponsible for connecting
 * to the native environment and streaming audio from the microphone.**/

class AudioStreamer {
  bool _isRecording = false;
  bool debug = false;
  List<double> _data = [];

  AudioStreamer({this.debug = false});

  static const EventChannel _noiseEventChannel =
      EventChannel(EVENT_CHANNEL_NAME);

  Stream<List<double>> _stream;
  StreamSubscription<List<dynamic>> _subscription;

  void _print(String t) {
    if (debug) print(t);
  }

  Stream<List<double>> get audioStream {
    if (_stream == null) {
      _stream = _noiseEventChannel
          .receiveBroadcastStream()
          .map((buffer) => buffer as List<dynamic>)
          .map((list) => list.map((e) => double.parse('$e')).toList());
    }
    return _stream;
  }

  static Future<bool> checkPermission() async {
    /// Verify that it was granted
    PermissionStatus permission = await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.microphone);
    return permission == PermissionStatus.granted;
  }

  static Future<void> requestPermission() async {
    /// Request the microphone permission
    await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
  }

  void onData(List<double> bufferData) {
    _data.addAll(bufferData);
  }

  Future<bool> start() async {
    _print('AudioStreamer: startRecorder()');

    if (_isRecording) {
      print('AudioStreamer: Already recording!');
      return _isRecording;
    } else {
      bool granted = await AudioStreamer.checkPermission();

      if (granted) {
        _print('AudioStreamer: Permission granted? $granted');
        try {
          _data = []; // Clear data
          _isRecording = true;
          _subscription = audioStream.listen(onData);
        } catch (err) {
          _print('AudioStreamer: startRecorder() error: $err');
        }
      } else {
        await AudioStreamer.requestPermission();
      }
    }
    return _isRecording;
  }

  Future<List<dynamic>> stop() async {
    _print('AudioStreamer: stopRecorder()');
    try {
      if (_subscription != null) {
        _subscription.cancel();
        _subscription = null;
      }
      _isRecording = false;
    } catch (err) {
      _print('AudioStreamer: stopRecorder() error: $err');
    }
    return _data;
  }
}
