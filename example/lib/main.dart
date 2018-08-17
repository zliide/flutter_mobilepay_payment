import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await FlutterMobilePayPayment.init("APPDK0000000000", Country.Denmark, captureType: CaptureType.Reserve);
    } on PlatformException {
      status = 'Failed to initialize AppSwitch.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _status = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('$_status\n'),
        ),
      ),
    );
  }
}
