# cough_detection

cough_detection plugin

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
## Example Usage (Audio Streaming)
```dart
bool recording = false;

void start() async {
  recording = await streamer.start();
}

void stop() async {
  recording = false;
  List data = await streamer.stop();
  
  print('Recording was stopped.');
  print('Number of data points: ${data.length}');
}
```
