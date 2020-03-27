import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:cough_detection/cough_detection.dart';
import 'dart:math';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isRecording = false;
  StreamSubscription<List<dynamic>> _noiseSubscription;
  AudioStreamer _audioStreamer;

  @override
  void initState() {
    super.initState();
  }

  void onData(List<dynamic> audioData) {
    this.setState(() {
      if (!this._isRecording) {
        this._isRecording = true;
      }
    });
    print(audioData.toString());
  }

  void startRecorder() async {
    print('startRecorder()');
    try {
      _audioStreamer = new AudioStreamer();
      _noiseSubscription = _audioStreamer.noiseStream.listen(onData);
    } catch (err) {
      print('startRecorder() error: $err');
    }
  }

  void stopRecorder() async {
    print('stopRecorder()');
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription.cancel();
        _noiseSubscription = null;
      }
      this.setState(() {
        this._isRecording = false;
      });
    } catch (err) {
      print('stopRecorder() error: $err');
    }
  }

  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'MIC ${(_isRecording ? 'ON' : 'OFF')}',
                style: Theme.of(context).textTheme.display1,
              ),
              Text(
                _isRecording ? "Data is being printed..." : '',
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (!this._isRecording) {
                return this.startRecorder();
              }
              this.stopRecorder();
            },
            child: Icon(this._isRecording ? Icons.stop : Icons.mic)),
      ),
    );
  }
}
