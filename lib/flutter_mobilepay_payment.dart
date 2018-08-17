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

class PaymentError extends Error {
  final String message;
  final int errorCode;
  PaymentError(this.message, this.errorCode);
  String toString() => message;
}

class PaymentResult {
  final String transactionId;
  final double amount;
  PaymentResult(this.transactionId, this.amount);
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

  static Future<PaymentResult> pay(String orderId, double amount) async {
    Map<dynamic, dynamic> result = await _channel.invokeMethod('pay', {
      'orderId': orderId,
      'amount': amount,
    });
    bool completed = result["completed"];
    if (!completed && result.containsKey("errorMessage")) {
      throw PaymentError(result["errorMessage"], result["errorCode"]);
    }
    if (!completed) {
      return null;
    }
    return PaymentResult(result["transactionId"], result["amount"]);
  }
}
