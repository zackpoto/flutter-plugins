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
  AudioStreamer streamer = AudioStreamer(debug: true);

  @override
  void initState() {
    super.initState();
  }

  void start() async {
    bool started = await streamer.start();
    setState(() {
      _isRecording = started;
    });
  }

  void stop() async {
    setState(() {
      _isRecording = false;
    });

    List data = await streamer.stop();
    print('Recording was stopped.');
    print('Number of data points: ${data.length}');
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
                _isRecording ? "Data is being recorded..." : '',
              ),

            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: _isRecording ? Colors.red : Colors.green,
            onPressed: _isRecording ? stop : start,
            child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic)),
      ),
    );
  }
}
