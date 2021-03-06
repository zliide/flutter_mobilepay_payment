[![pub package](https://img.shields.io/pub/v/flutter_mobilepay_payment.svg)](https://pub.dartlang.org/packages/flutter_mobilepay_payment)

# Flutter MobilePay payment

A Flutter plugin for integrating Scandinavian payment provider MobilePay.

Only Android support for now.

## Usage

Install the package by adding the line `flutter_mobilepay_payment: ^0.1.0` to `pubspec.yaml` and run `flutter packages get`.

Import it in `main.dart`;
```dart
import 'package:flutter_mobilepay_payment/flutter_mobilepay_payment.dart';
```

and once in your app, initialize a `AppSwitchPayment` instance:
```dart
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  static AppSwitchPayment _mobilePay = AppSwitchPayment(
      "APPDK0000000000", Country.Denmark,
      captureType: CaptureType.Reserve);

  @override
  _MyAppState createState() => _MyAppState(_mobilePay);
}
```

Then do a payment like this:
```dart
final payment = await mobilePay.pay("86715c57-8840-4a6f-af5f-07ee89107ece", 10.0);
```

If `payment` is `null`, that means that the payment was cancelled, i.e. the user backed out.
If an error occurs, an exception will be thrown with the corresponding [error code](https://github.com/MobilePayDev/MobilePay-AppSwitch-SDK/wiki/Error-handling).
Otherwise, the `payment` object will contain the paid amount and the transaction ID.

At this point you would want to process the payment, e.g. by sending the order ID and transaction ID to your backend. When the process completes succesfully, call
```dart
await payment.complete();
```

If the app fails to process the payment, or even if it crashes after returning from AppSwitch, the uncompleted payment will be accessible through
```dart
final payment = await incompletePayment();
```

You should check for that when your app starts, and if it is non-`null`, resume the app in the state where it is processing the payment.

## MobilePay

The plugin has MobilePay AppSwitch SDK v. 1.8.1 built in. See [here](https://github.com/MobilePayDev/MobilePay-AppSwitch-SDK/tree/master/sdk/Android) if it's the latest one.

## Troubleshooting

Q: I got a lovely `java.lang.AbstractMethodError (no error message)` from gradle after installing the package.
A: That's been seen when using Kotlin 1.2.50, and it was fixed by upgrading to 1.2.60.

## Flutter

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/platform-plugins/#edit-code).