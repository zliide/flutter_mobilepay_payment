import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_mobilepay_payment/flutter_mobilepay_payment.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CaptureType _captureType = CaptureType.Reserve;
  String _status = "Ready";

  Future<void> pay() async {
    try {
      final mobilePay = AppSwitchPayment("APPDK0000000000", Country.Denmark,
          captureType: _captureType);
      final payment =
          await mobilePay.pay("86715c57-8840-4a6f-af5f-07ee89107ece", 10.0);

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      if (payment == null) {
        return;
      }

      setState(() {
        _status =
            "Payment completed (ref. ${payment.transactionId.substring(0, 8)}).";
      });
    } on PaymentError catch (e) {
      if (!mounted) return;
      setState(() {
        _status = "Payment error: ${e.message} (code ${e.errorCode}).";
      });
    }
  }

  void _handleRadioValueChange(CaptureType value) {
    setState(() {
      _captureType = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(_status),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Radio(
                      value: CaptureType.Capture,
                      groupValue: _captureType,
                      onChanged: _handleRadioValueChange,
                    ),
                    Text('Capture'),
                    Radio(
                      value: CaptureType.Reserve,
                      groupValue: _captureType,
                      onChanged: _handleRadioValueChange,
                    ),
                    Text('Reserve'),
                    Radio(
                      value: CaptureType.PartialCapture,
                      groupValue: _captureType,
                      onChanged: _handleRadioValueChange,
                    ),
                    Text('Partial capture'),
                  ],
                ),
                FlatButton(
                  child: Text('Pay'),
                  onPressed: pay,
                )
              ]),
        ),
      ),
    );
  }
}
