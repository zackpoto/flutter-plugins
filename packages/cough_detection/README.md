# cough_detection

Plugin for detecting and labelling coughs in real time.

## Permissions
On *Android* you need to add a permission to `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

On *iOS* enable the following:
* Capabilities > Background Modes > _Audio, AirPlay and Picture in Picture_
* In the Runner Xcode project edit the _Info.plist_ file. Add an entry for _'Privacy - Microphone Usage Description'_

When editing the `Info.plist` file manually, the entries needed are:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>YOUR DESCRIPTION</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
</array>
```

## Data Model
A cough can be either Dry or Productive (Wet) and happens at a given time. The Cough class therefore has the following fields:

```dart
DateTime date
CoughType coughType
```

## Example Usage 
See the file `example/lib/main.dart` for a fully fledged example app using the plugin.

```dart
CoughDetector _coughDetector = CoughDetector();
bool _isRecording = false;
List<Cough> _coughs = [];

/// Handles new detected coughs
void onCough(Cough cough) {
  print('Received cough from stream: $cough');
  setState(() {
    _coughs.add(cough);
  });
}

/// Starts detection
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

/// Stops detection
void stop() async {
  bool stopped = await _coughDetector.stopDetection();
  setState(() {
    _isRecording = stopped;
  });
}
```
