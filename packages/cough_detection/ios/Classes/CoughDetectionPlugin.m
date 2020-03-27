#import "CoughDetectionPlugin.h"
#if __has_include(<cough_detection/cough_detection-Swift.h>)
#import <cough_detection/cough_detection-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "cough_detection-Swift.h"
#endif

@implementation CoughDetectionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCoughDetectionPlugin registerWithRegistrar:registrar];
}
@end
