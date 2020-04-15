part of cough_detection;

const String EVENT_CHANNEL_NAME = 'cough_detection.eventChannel';

/** A [CoughDetector] analyzes audio data.**/
class CoughDetector {
  //TODO: USE DEPENDENCY INJECTION! IF YOU SEE THIS WE HAVE FAILED AS HUMAN BEINGS: USING STATIC IS NOT OKAY D:
  static _AudioStreamer audioStreamer = _AudioStreamer();
  static bool isRecording = false;
  static List<double> flutterBuffer = [];
  static double threshold = 0.35; //0.85;
  static int segLength = 1024;
  static double overlap = 0.75;
  static Matrix matrix = Matrix(melMatrix);//Matrix(melMatrix);
  static StreamController<Cough> controller;

  /// - stopping detection
  Future<bool> stopDetection() async {
    await controller.close();
    isRecording = false;
    return await audioStreamer.stop();
  }

  /// Start detection, i.e. listening to the cough stream
  void startDetection(Function onData) async{
    Tflite.close();
      try {
        String res = await Tflite.loadModel(
            model: "assets/spectrogram_cough_detector_3chan.tflite",
            labels: "assets/spectrogram_cough_detector_labels.txt");
            //model: "assets/yamnet.tflite",
            //labels: "assets/yamnet.labels.txt");
        isRecording = true;
        print(res);
        _getCoughStream().listen(onData);
      } on PlatformException {
        print('Failed to load model.');
        isRecording = false;
      }
  }

  Stream<Cough> _getCoughStream() {
    controller = StreamController<Cough>.broadcast(onListen: () async {
      await audioStreamer.start((List<double> audioBufferData) {
        /// Do stuff with data
        int T = 10; // Recording segment length in seconds
        int samplerate = 44100; // Number of samples per sec
        int windowSize = samplerate * T; // Samples per segment

        flutterBuffer.addAll(audioBufferData);
        if (flutterBuffer.length >= windowSize) {
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
            var coughDate = DateTime.now();
            print('Sound detected');
            detectCough(flutterBuffer, segLength, overlap, matrix, coughDate).then((res){
              print("RESULT SAYS: ${res == true ? "Cough was detected!" : "No cough detected."}");
              if(res){
                Cough cough = new Cough(coughDate, coughTypeRandom);
                controller.add(cough);
              }
            });
            
          }
          flutterBuffer = [];
        }
      });
    });
    return controller.stream;
  }

  Future<bool> detectCough(List<double> flutterBuffer, int segLength, double overlap,
      Matrix matrix, DateTime coughDate) async {
    // Spectrogram Conversion
    var transformMatrix = Spectrogram.makeLogMelSpectrogram(
        flutterBuffer, segLength, overlap, matrix);

    //save as image
    Directory tempDir = await getTemporaryDirectory();

    String path = await Spectrogram.createImage(
        transformMatrix, "${tempDir.path}/${coughDate.toIso8601String()}.png");
    print(path);
    if (Platform.isAndroid) {
      try {
        var recognitions = await Tflite.runModelOnImage(
          path: path,
          numResults: 6,
          threshold: 0.05,
          imageMean: 127.5,
          imageStd: 127.5,
        );
        print(recognitions);
        return true;
      } catch (err) {
        return false;
      }
    } else if (Platform.isIOS) {
      try {
        var recognitions = await Tflite.runModelOnImage(
          path: path,
          numResults: 6,
          threshold: 0.05,
          imageMean: 127.5,
          imageStd: 127.5,
        );
        print(recognitions);
        return true;
      } catch (err) {
        return false;
      }
    }
    return false;
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
