#import "FlutterMobilepayPaymentPlugin.h"
#if __has_include(<flutter_mobilepay_payment/flutter_mobilepay_payment-Swift.h>)
#import <flutter_mobilepay_payment/flutter_mobilepay_payment-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_mobilepay_payment-Swift.h"
#endif

@implementation FlutterMobilepayPaymentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMobilepayPaymentPlugin registerWithRegistrar:registrar];
}
@end
