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

enum ErrorCategory {
  Generic,
  Timeout,
  MobilePayAppOutOfDate,
  MerchantAppOutOfDate,
  InsufficientFunds,
}

Map<int, ErrorCategory> _categories = {
  2: ErrorCategory.Generic,
  3: ErrorCategory.MobilePayAppOutOfDate,
  6: ErrorCategory.Timeout,
  7: ErrorCategory.InsufficientFunds,
  8: ErrorCategory.Timeout,
  9: ErrorCategory.Generic,
  10: ErrorCategory.MerchantAppOutOfDate,
  11: ErrorCategory.Generic,
};

class PaymentException implements Exception {
  final String message;
  final int errorCode;
  final ErrorCategory category;
  PaymentException(this.message, this.errorCode)
      : category = _categories[errorCode];
  String toString() => message;
}

final _channel = const MethodChannel('flutter_mobilepay_payment');

class PaymentResult {
  final String orderId;
  final String transactionId;
  final double amount;
  PaymentResult(this.orderId, this.transactionId, this.amount);

  Future complete() => _channel.invokeMethod('paymentComplete');
}

Future<PaymentResult> incompletePayment() async {
  final result = await _channel.invokeMethod('incompletePayment');
  if (result == null) {
    return null;
  }
  return PaymentResult(
      result['orderId'], result['transactionId'], result['amount']);
}

class _AppSwitchState {
  final _mutex = Mutex();
  String _merchantId;
  Country _country;
  CaptureType _captureType;

  Future<Map<dynamic, dynamic>> pay(String merchantId, Country country,
          CaptureType captureType, String orderId, double amount) =>
      _lock(_mutex, () async {
        if (await incompletePayment() != null) {
          throw StateError(
              'A payment is awaiting completion. Please call complete() on the payment when the processing of the payment has been completed, and check incompletePayment() to see if any pending incomplete payments needs to be completed.');
        }
        ArgumentError.checkNotNull(merchantId, 'merchantId');
        if (_merchantId != merchantId ||
            _country != country ||
            _captureType == captureType) {
          await _channel.invokeMethod('init', {
            'merchantId': merchantId,
            'country': country.index,
            'captureType': captureType.index,
          });
          _merchantId = merchantId;
          _country = country;
          _captureType = captureType;
        }
        return await _channel.invokeMethod('pay', {
          'orderId': orderId,
          'amount': amount,
        });
      });
}

final _state = _AppSwitchState();

class AppSwitchPayment {
  final String _merchantId;
  final Country _country;
  final CaptureType _captureType;

  AppSwitchPayment(String merchantId, Country country,
      {CaptureType captureType: CaptureType.Capture})
      : _merchantId = merchantId,
        _country = country,
        _captureType = captureType;

  Future<PaymentResult> pay(String orderId, double amount) async {
    final result =
        await _state.pay(_merchantId, _country, _captureType, orderId, amount);
    bool completed = result["completed"];
    if (!completed && result.containsKey("errorCode")) {
      if ([1, 4, 5, 11].contains(result["errorCode"])) {
        throw PaymentError(result["errorMessage"], result["errorCode"]);
      } else {
        throw PaymentException(result["errorMessage"], result["errorCode"]);
      }
    }
    if (!completed) {
      return null;
    }
    return PaymentResult(orderId, result["transactionId"], result["amount"]);
  }
}

class Mutex {
  Future<void> _future;
}

typedef Future<T> _AsyncFn<T>();

Future<T> _lock<T>(Mutex m, _AsyncFn<T> fn) async {
  if (m._future != null) {
    try {
      await m._future;
    } catch (e) {}
  }
  final f = fn();
  m._future = f;
  return await f;
}
