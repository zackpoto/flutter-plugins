part of cough_detection;

const String EVENT_CHANNEL_NAME = 'cough_detection.eventChannel';

/** A [CoughDetector] analyzes audio data.**/
class CoughDetector {
  _AudioStreamer audioStreamer = _AudioStreamer();
  List<double> flutterBuffer = [];
  double threshold = 0.85;
  StreamController<Cough> controller;

  /// PUBLIC METHODS
  /// - starting detection
  Future<bool> startDetection() async {
    return await audioStreamer.start(_onData);
  }

  /// - stopping detection
  Future<bool> stopDetection() async {
    await controller.close();
    return await audioStreamer.stop();
  }

  /// - reading saved coughs
//  Future<List<Cough>> readLocalCoughs() async {
//    return await FileHandler.readCoughs();
//  }

  Stream<Cough> get coughStream {
    controller = StreamController<Cough>.broadcast(onListen: () async {
      await audioStreamer.start((List<double> audioBufferData) {
        /// Do stuff with data
        int T = 2; // Recording segment length in seconds
        int flutterBufferSize = 2 * audioBufferData.length * T;

        flutterBuffer.addAll(audioBufferData);
        if (flutterBuffer.length >= flutterBufferSize) {
          print('Analyzing data of size: ${flutterBuffer.length}');
          print('max amp: ${flutterBuffer.reduce(max)}');
          print('min amp: ${flutterBuffer.reduce(min)}');

          /// Thresholding
          double maxAmp = flutterBuffer.reduce(max);
          double minAmp = flutterBuffer.reduce(min);
          minAmp = minAmp < 0 ? minAmp * -1 : minAmp;

          /// Detection
          if (maxAmp > threshold || minAmp > threshold) {
            /// Detect cough type
            var types = [CoughType.DRY, CoughType.PRODUCTIVE];
            var coughTypeRandom = types[Random().nextInt(types.length)];
            Cough cough = new Cough(DateTime.now(), coughTypeRandom);
            print('Cough detected: [$cough]');

            /// Store on device
            controller.add(cough);
          }
          flutterBuffer = [];
        }
      });
    });
    return controller.stream;
  }

  /// Private internal methods for analyzing incoming data
  void _onData(List<double> audioBufferData) {
    /// Do stuff with data
    int T = 2; // Recording segment length in seconds
    int flutterBufferSize = 2 * audioBufferData.length * T;

    flutterBuffer.addAll(audioBufferData);
    if (flutterBuffer.length >= flutterBufferSize) {
      print('Analyzing data of size: ${flutterBuffer.length}');
      _analyzeData(flutterBuffer);
      flutterBuffer = [];
    }
  }

  void _analyzeData(List<double> data) async {
    print('max amp: ${data.reduce(max)}');
    print('min amp: ${data.reduce(min)}');

    /// Thresholding
    double maxAmp = data.reduce(max);
    double minAmp = data.reduce(min);
    minAmp = minAmp < 0 ? minAmp * -1 : minAmp;

    /// Detection
    if (maxAmp > threshold || minAmp > threshold) {
      /// Detect cough type
      var types = [CoughType.DRY, CoughType.PRODUCTIVE];
      var coughTypeRandom = types[Random().nextInt(types.length)];
      Cough cough = new Cough(DateTime.now(), coughTypeRandom);
      print('Cough detected: [$cough]');

      /// Store on device
//      FileHandler.writeCoughToFile(cough);
    }
  }
}

/** A [_AudioStreamer] object is reponsible for connecting
 * to the native environment and streaming audio from the microphone.**/

class _AudioStreamer {
  bool _isRecording = false;
  bool debug = false;

  _AudioStreamer({this.debug = false});

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

  Future<bool> start(Function onData) async {
    _print('AudioStreamer: startRecorder()');

    if (_isRecording) {
      print('AudioStreamer: Already recording!');
      return _isRecording;
    } else {
      bool granted = await _AudioStreamer.checkPermission();

      if (granted) {
        _print('AudioStreamer: Permission granted? $granted');
        try {
          _isRecording = true;
          _subscription = audioStream.listen(onData);
        } catch (err) {
          _print('AudioStreamer: startRecorder() error: $err');
        }
      } else {
        await _AudioStreamer.requestPermission();
      }
    }
    return _isRecording;
  }

  Future<bool> stop() async {
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
    return _isRecording;
  }
}
