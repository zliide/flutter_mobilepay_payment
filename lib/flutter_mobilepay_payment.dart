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

class AppSwitchPayment {
  MethodChannel _channel;
  static Future<void> _initFuture;

  AppSwitchPayment(String merchantId, Country country, {CaptureType captureType: CaptureType.Capture}) {
    if(_initFuture != null) {
      throw StateError("Multiple AppSwitchPayment instances not supported.");
    }
    _channel = const MethodChannel('flutter_mobilepay_payment');
    _initFuture = _channel.invokeMethod('init', {
      'merchantId': merchantId,
      'country': country.index,
      'captureType': captureType.index,
    });
  }

  Future<PaymentResult> pay(String orderId, double amount) async {
    await _initFuture;
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
