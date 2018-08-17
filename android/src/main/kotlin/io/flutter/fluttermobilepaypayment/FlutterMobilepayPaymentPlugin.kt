package io.flutter.fluttermobilepaypayment

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import dk.danskebank.mobilepay.sdk.*

import android.util.Log

class FlutterMobilepayPaymentPlugin(): MethodCallHandler {
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar): Unit {
      val channel = MethodChannel(registrar.messenger(), "flutter_mobilepay_payment")
      channel.setMethodCallHandler(FlutterMobilepayPaymentPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result): Unit {
    if (call.method == "init") {
      val merchantId: String = call.argument("merchantId")
      val countryIndex: Int = call.argument("country")
      val country = when(countryIndex) {
        0 -> Country.DENMARK
        1 -> Country.FINLAND
        2 -> Country.NORWAY
        else -> throw IllegalArgumentException("Unsupported country.")
      }
      val captureIndex: Int = call.argument("captureType")
      val captureType = when(captureIndex) {
        0 -> CaptureType.RESERVE
        1 -> CaptureType.CAPTURE
        2 -> CaptureType.PARTIAL_CAPTURE
        else -> throw IllegalArgumentException("Unsupported capture type.")
      }
      MobilePay.getInstance().apply {
        init(merchantId, country)
        setCaptureType(captureType)
      }
      Log.d("FlutterMobilepayPaymentPlugin",
              "MobilePay initialized with merchant ID ${merchantId} with capture type ${captureType}.")
      result.success(null)
    } else {
      result.notImplemented()
    }
  }
}
