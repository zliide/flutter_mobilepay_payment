#import "FlutterMobilepayPaymentPlugin.h"
#import <flutter_mobilepay_payment/flutter_mobilepay_payment-Swift.h>

@implementation FlutterMobilepayPaymentPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMobilepayPaymentPlugin registerWithRegistrar:registrar];
}
@end
