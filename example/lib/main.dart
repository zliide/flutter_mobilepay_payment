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
  PaymentResult _payment;

  @override
  void initState() {
    super.initState();
    _getIncompletePayment();
  }

  Future _getIncompletePayment() async {
    final payment = await incompletePayment();
    if (payment != null) {
      setState(() {
        _payment = payment;
      });
    }
  }

  Future<void> pay() async {
    try {
      final mobilePay = AppSwitchPayment("APPDK0000000000", Country.Denmark,
          captureType: _captureType);

      final payment =
          await mobilePay.pay("86715c57-8840-4a6f-af5f-07ee89107ece", 10.0);

      if (payment == null) {
        return;
      }

      // If the widget was removed from the tree while the asynchronous platform
      // message was in flight, we want to discard the reply rather than calling
      // setState to update our non-existent appearance.
      if (!mounted) return;

      setState(() {
        _payment = payment;
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
  Widget build(BuildContext context) => MaterialApp(
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
                    onPressed: _payment == null ? pay : null,
                  ),
                  FlatButton(
                    child: Text('Process payment'),
                    onPressed: _payment != null
                        ? () async {
                            print('Processing order ${_payment.orderId}');
                            await _payment.complete();
                            setState(() {
                              _payment = null;
                            });
                          }
                        : null,
                  ),
                ]),
          ),
        ),
      );
}
