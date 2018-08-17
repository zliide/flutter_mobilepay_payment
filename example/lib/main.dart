import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_mobilepay_payment/flutter_mobilepay_payment.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  static AppSwitchPayment _mobilePay = AppSwitchPayment("APPDK0000000000", Country.Denmark, captureType: CaptureType.Reserve);

  @override
  _MyAppState createState() => new _MyAppState(_mobilePay);
}

class _MyAppState extends State<MyApp> {
  AppSwitchPayment mobilePay;
  String _status = "Ready";

  _MyAppState(this.mobilePay);

  Future<void> pay() async {
    try {
      var payment = await mobilePay.pay("86715c57-8840-4a6f-af5f-07ee89107ece", 10.0);

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      if (payment == null) {
        return;
      }

      setState(() {
        _status = "Payment completed (ref. ${payment.transactionId.substring(0, 8)}).";
      });
    } on PaymentError catch (e) {
      if (!mounted) return;
      setState(() {
        _status = "Payment error: ${e.message} (code ${e.errorCode}).";
      });
    }
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$_status\n'),
                FlatButton(
                  child: Text('Pay'),
                  onPressed: pay,
                )
              ]
          ),
        ),
      ),
    );
  }
}
