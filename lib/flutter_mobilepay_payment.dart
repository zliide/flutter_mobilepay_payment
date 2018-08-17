import 'dart:async';

import 'package:flutter/services.dart';

enum Country {
  Denmark,
  Finland,
  Norway,
}

enum CaptureType {
  Reserve,
  Capture,
  PartialCapture,
}

class FlutterMobilePayPayment {
  static const MethodChannel _channel =
      const MethodChannel('flutter_mobilepay_payment');

  static Future<void> init(String merchantId, Country country, {CaptureType captureType: CaptureType.Capture}) async {
    await _channel.invokeMethod('init', {
      'merchantId': merchantId,
      'country': country.index,
      'captureType': captureType.index,
    });
  }
}
