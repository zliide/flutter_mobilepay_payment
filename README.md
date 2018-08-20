[![pub package](https://img.shields.io/pub/v/flutter_mobilepay_payment.svg)](https://pub.dartlang.org/packages/flutter_mobilepay_payment)

# Flutter MobilePay payment

A Flutter plugin for integrating Scandinavian payment provider MobilePay.

Only Android support for now.

## Usage

Install the package by adding the line `flutter_mobilepay_payment: ^0.0.1` to `pubspec.yaml` and run `flutter packages get`.

Import it in `main.dart`;
```dart
import 'package:flutter_mobilepay_payment/flutter_mobilepay_payment.dart';
```

and once in your app, initialize a `AppSwitchPayment` instance:
```dart
void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  static AppSwitchPayment _mobilePay = AppSwitchPayment(
      "APPDK0000000000", Country.Denmark,
      captureType: CaptureType.Reserve);

  @override
  _MyAppState createState() => new _MyAppState(_mobilePay);
}
```

Then do a payment like this:
```dart
final payment = await mobilePay.pay("86715c57-8840-4a6f-af5f-07ee89107ece", 10.0);
```

If `payment` is `null`, that means that the payment was cancelled, i.e. the user backed out.
If an error occurs, an exception will be thrown with the corresponding [error code](https://github.com/MobilePayDev/MobilePay-AppSwitch-SDK/wiki/Error-handling).
Otherwise, the `payment` object will contain the paid amount and the transaction ID.

## Flutter

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).