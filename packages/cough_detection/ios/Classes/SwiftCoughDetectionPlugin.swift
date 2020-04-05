import Flutter
import UIKit
import AVFoundation

public class SwiftCoughDetectionPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

  private var eventSink: FlutterEventSink?
  var engine = AVAudioEngine()
  var audioData: [Float] = []
  var recording = false

  // Register plugin
  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SwiftCoughDetectionPlugin()
    
    // Set flutter communication channel for emitting updates
    let eventChannel = FlutterEventChannel.init(name: "cough_detection.eventChannel", binaryMessenger: registrar.messenger())
    eventChannel.setStreamHandler(instance)
  }

    // Handle stream emitting (Swift => Flutter)
    private func emitValues(values: [Float]) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit values count event to Flutter
        eventSink!(values)
    }

    // Event Channel: On Stream Listen
    public func onListen(withArguments arguments: Any?, 
      eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        startRecording()
        return nil
    }

    // Event Channel: On Stream Cancelled
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil
        engine.stop()
        //self.emitValues(values: audioData)
        return nil
    }

    func startRecording() {
        engine = AVAudioEngine()
        let input = engine.inputNode
        let bus = 0
        
        input.installTap(onBus: bus, bufferSize: 22050, format: input.inputFormat(forBus: bus)) { (buffer, time) -> Void in
            let samples = buffer.floatChannelData?[0]
            // audio callback, samples in samples[0]...samples[buffer.frameLength-1]
            let arr = Array(UnsafeBufferPointer(start: samples, count: Int(buffer.frameLength)))
            self.emitValues(values: arr)
        }
        
        try! engine.start()
    }

}


// public class SwiftCoughDetectionPlugin: NSObject, FlutterPlugin {
//   public static func register(with registrar: FlutterPluginRegistrar) {
//     let channel = FlutterMethodChannel(name: "cough_detection", binaryMessenger: registrar.messenger())
//     let instance = SwiftCoughDetectionPlugin()
//     registrar.addMethodCallDelegate(instance, channel: channel)
//   }

//   public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//     result("iOS " + UIDevice.current.systemVersion)
//   }
// }