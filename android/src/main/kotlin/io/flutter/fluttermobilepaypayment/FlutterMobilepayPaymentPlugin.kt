package io.flutter.fluttermobilepaypayment

import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import dk.danskebank.mobilepay.sdk.*

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import dk.danskebank.mobilepay.sdk.model.FailureResult
import dk.danskebank.mobilepay.sdk.model.Payment
import dk.danskebank.mobilepay.sdk.model.SuccessResult
import java.math.BigDecimal

const val LogTag = "MobilePayPaymentPlugin"
const val RequestCode: Int = 1513201027

class FlutterMobilepayPaymentPlugin(private val activity: Activity): MethodCallHandler, ActivityResultListener {
  private var payResult: Result? = null

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val plugin = FlutterMobilepayPaymentPlugin(registrar.activity())
      registrar.addActivityResultListener(plugin)
      val channel = MethodChannel(registrar.messenger(), "flutter_mobilepay_payment")
      channel.setMethodCallHandler(plugin)
    }
  }

  private var mobilePayAppSwitchIncompletePayment: SharedPreferences = activity.applicationContext
          .getSharedPreferences("mobilePayAppSwitchIncompletePayment", Context.MODE_PRIVATE)

  override fun onMethodCall(call: MethodCall, result: Result) = when (call.method) {
    "init" -> {
      val merchantId: String = call.argument("merchantId")!!
      val countryIndex: Int = call.argument("country")!!
      val country = when (countryIndex) {
        0 -> Country.DENMARK
        1 -> Country.FINLAND
        2 -> Country.NORWAY
        else -> throw IllegalArgumentException("Unsupported country.")
      }
      val captureIndex: Int = call.argument("captureType")!!
      val captureType = when (captureIndex) {
        0 -> CaptureType.RESERVE
        1 -> CaptureType.CAPTURE
        2 -> CaptureType.PARTIAL_CAPTURE
        else -> throw IllegalArgumentException("Unsupported capture type.")
      }
      MobilePay.getInstance().apply {
        init(merchantId, country)
        setCaptureType(captureType)
      }
      Log.d(LogTag,
              "MobilePay initialized with merchant ID $merchantId and capture type $captureType.")
      result.success(null)
    }
    "pay" -> {
      val orderId: String = call.argument("orderId")!!
      val amount: Double = call.argument("amount")!!
      val instance = MobilePay.getInstance()

      val mobilePayIsInstalled = instance.isMobilePayInstalled(activity)
      if (mobilePayIsInstalled) {
        if(payResult != null) {
          throw IllegalStateException("Payment already in progress.")
        }
        val payment = Payment().apply {
          setOrderId(orderId)
          productPrice = BigDecimal(amount)
        }
        val payIntent = instance.createPaymentIntent(payment)
        activity.startActivityForResult(payIntent, RequestCode)
        payResult = result
      } else {
        Log.d(LogTag, "MobilePay app not installed - redirecting to Play Store.")
        val playStoreIntent = instance.createDownloadMobilePayIntent(activity)
        activity.startActivity(playStoreIntent)
        result.success(mapOf (
          "completed" to false
        ))
      }
    }
    "incompletePayment" -> {
      if (!mobilePayAppSwitchIncompletePayment.contains("orderId")) {
        result.success(null)
      }
      else {
        result.success(mapOf(
                "orderId" to mobilePayAppSwitchIncompletePayment.getString("orderId", null),
                "transactionId" to mobilePayAppSwitchIncompletePayment.getString("transactionId", null),
                "amount" to mobilePayAppSwitchIncompletePayment.getFloat("amount", 0.0f).toDouble()
        ))
      }
    }
    "paymentComplete" -> {
      mobilePayAppSwitchIncompletePayment
              .edit()
              .remove("orderId")
              .remove("transactionId")
              .remove("amount")
              .apply()
      result.success(null)
    }
    else -> result.notImplemented()
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
    if (requestCode != RequestCode) {
      return false
    }
    val result = payResult
    payResult = null
    if (result == null) {
      Log.e(LogTag, "MobilePay AppSwitch returned without it being called.")
      return false
    }
    MobilePay.getInstance().handleResult(resultCode, data, object: ResultCallback {
      override fun onSuccess(res: SuccessResult) {
        Log.d(LogTag, "MobilePay AppSwitch payment succeeded.")
        mobilePayAppSwitchIncompletePayment
                .edit()
                .putString("orderId", res.orderId)
                .putString("transactionId", res.transactionId)
                .putFloat("amount", res.amountWithdrawnFromCard.toFloat())
                .apply()
        result.success(mapOf (
          "completed" to true,
          "transactionId" to res.transactionId,
          "amount" to res.amountWithdrawnFromCard.toDouble()
        ))
      }

      override fun onFailure(res: FailureResult) {
        Log.e(LogTag, "MobilePay AppSwitch payment failed.")
        result.success(mapOf (
          "completed" to false,
          "errorCode" to res.errorCode,
          "errorMessage" to res.errorMessage
        ))
      }

      override fun onCancel() {
        Log.d(LogTag, "MobilePay AppSwitch payment cancelled.")
        result.success(mapOf (
          "completed" to false
        ))
      }
    })
    return true
  }
}
