import 'dart:async';

import 'package:flutter/services.dart';

class FlutterMobilepayPayment {
  static const MethodChannel _channel =
      const MethodChannel('flutter_mobilepay_payment');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
