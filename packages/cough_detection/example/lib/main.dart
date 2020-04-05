import 'package:flutter/material.dart';
import 'package:cough_detection/cough_detection.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CoughDetector _coughDetector = CoughDetector();
  bool _isRecording = false;
  List<Cough> _coughs = [];

  @override
  void initState() {
    super.initState();
  }

  void onCough(Cough cough) {
    print('Received cough from stream: $cough');
    setState(() {
      _coughs.add(cough);
    });
  }

  void start() async {
    try {
      _coughDetector.startDetection(onCough);
      setState(() {
        _isRecording = true;
      });
    } catch (error) {
      print(error);
    }
  }

  void stop() async {
    bool stopped = await _coughDetector.stopDetection();
    setState(() {
      _isRecording = stopped;
    });
  }

  List<Widget> getContent() => <Widget>[
        Container(
            margin: EdgeInsets.all(25),
            child: Column(children: [
              Container(
                child: Text(_isRecording ? "Detection: ON" : "Detection: OFF",
                    style: TextStyle(fontSize: 25, color: Colors.blue)),
                margin: EdgeInsets.only(top: 20),
              )
            ])),
        Expanded(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: _coughs.length,
              itemBuilder: (BuildContext context, int index) {
                Cough c = _coughs.reversed.toList()[index];
                return Container(
                    margin: EdgeInsets.all(5),
                    child: ListTile(
                      leading: Icon(
                        Icons.favorite,
                        color: c.coughType == CoughType.DRY
                            ? Colors.red
                            : Colors.green,
                      ),
                      title: Text(c.coughType.toString()),
                      subtitle: Text(
                        c.date.toIso8601String(),
                        style: TextStyle(fontSize: 10),
                      ),
                    ));
              }),
        )
      ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: getContent())),
        floatingActionButton: FloatingActionButton(
            backgroundColor: _isRecording ? Colors.red : Colors.green,
            onPressed: _isRecording ? stop : start,
            child: _isRecording ? Icon(Icons.stop) : Icon(Icons.mic)),
      ),
    );
  }
}
