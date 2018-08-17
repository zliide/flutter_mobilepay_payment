import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_mobilepay_payment/flutter_mobilepay_payment.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String status = "MobilePay AppSwitch initialized.";

    await FlutterMobilePayPayment.init("APPDK0000000000", Country.Denmark, captureType: CaptureType.Reserve);

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _status = status;
    });
  }

  Future<void> pay() async {
    try {
      var payment = await FlutterMobilePayPayment.pay("86715c57-8840-4a6f-af5f-07ee89107ece", 10.0);

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      if (payment == null) {
        return;
      }

      setState(() {
        _status = "Payment completed (ref. ${payment.transactionId}).";
      });
    } on PaymentError catch(e) {
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
              children: [Text('$_status\n'), FlatButton(
              child: Text('Pay'),
              onPressed: pay,
            )]
          ),
        ),
      ),
    );
  }
}
