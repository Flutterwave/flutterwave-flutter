import 'package:flutter/material.dart';
import 'package:flutterwave/core/flutterwave_error.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';
import 'package:flutterwave/widgets/home/flutterwave_payment.dart';

import 'flutterwave_payment_manager.dart';

class Flutterwave {
  BuildContext context;
  String publicKey;
  String encryptionKey;
  bool isDebugMode;
  String amount;
  String currency;
  String email;
  String fullName;
  String txRef;
  String redirectUrl;
  bool acceptAccountPayment;
  bool acceptCardPayment;
  bool acceptUSSDPayment;
  bool acceptRwandaMoneyPayment;
  bool acceptMpesaPayment;
  bool acceptZambiaPayment;
  bool acceptGhanaPayment;
  bool acceptUgandaPayment;
  bool acceptFrancophoneMobileMoney;
  bool acceptBankTransfer;
  String phoneNumber;
  int? frequency;
  int duration;
  bool isPermanent;
  String narration;
  String? country;

  /// Flutterwave Constructor
  Flutterwave.forUIPayment(
      {required this.context,
      required this.publicKey,
      required this.encryptionKey,
      required this.currency,
      required this.amount,
      required this.email,
      required this.fullName,
      required this.txRef,
      required this.isDebugMode,
      required this.phoneNumber,
      this.frequency,
      this.duration = 0,
      this.isPermanent = false,
      this.narration = "",
      this.acceptAccountPayment = false,
      this.acceptCardPayment = false,
      this.acceptUSSDPayment = false,
      this.acceptRwandaMoneyPayment = false,
      this.acceptMpesaPayment = false,
      this.acceptZambiaPayment = false,
      this.acceptGhanaPayment = false,
      this.acceptUgandaPayment = false,
      this.acceptFrancophoneMobileMoney = false,
      this.acceptBankTransfer = false,
      this.redirectUrl = ""}) {
    _validateKeys();
    this.currency = this.currency.toUpperCase();

    if (this.currency == FlutterwaveCurrency.NGN) {
      this.acceptRwandaMoneyPayment = false;
      this.acceptMpesaPayment = false;
      this.acceptZambiaPayment = false;
      this.acceptGhanaPayment = false;
      this.acceptUgandaPayment = false;
      this.acceptFrancophoneMobileMoney = false;
    } else if (this.currency == FlutterwaveCurrency.KES) {
      this.acceptMpesaPayment = true;

      this.acceptRwandaMoneyPayment = false;
      this.acceptZambiaPayment = false;
      this.acceptGhanaPayment = false;
      this.acceptUgandaPayment = false;
      this.acceptFrancophoneMobileMoney = false;
      this.acceptAccountPayment = false;
      this.acceptBankTransfer = false;
    } else if (this.currency == FlutterwaveCurrency.RWF) {
      this.acceptRwandaMoneyPayment = true;

      this.acceptMpesaPayment = false;
      this.acceptZambiaPayment = false;
      this.acceptGhanaPayment = false;
      this.acceptUgandaPayment = false;
      this.acceptFrancophoneMobileMoney = false;
      this.acceptAccountPayment = false;
      this.acceptUSSDPayment = false;
      this.acceptBankTransfer = false;
    } else if (this.currency == FlutterwaveCurrency.UGX) {
      this.acceptUgandaPayment = true;
      this.acceptMpesaPayment = false;
      this.acceptZambiaPayment = false;
      this.acceptGhanaPayment = false;
      this.acceptFrancophoneMobileMoney = false;
      this.acceptAccountPayment = false;
      this.acceptUSSDPayment = false;
      this.acceptRwandaMoneyPayment = false;
      this.acceptBankTransfer = false;
    } else if (this.currency == FlutterwaveCurrency.ZMW) {
      this.acceptZambiaPayment = true;

      this.acceptAccountPayment = false;
      this.acceptRwandaMoneyPayment = false;
      this.acceptMpesaPayment = false;
      this.acceptGhanaPayment = false;
      this.acceptUgandaPayment = false;
      this.acceptFrancophoneMobileMoney = false;
      this.acceptUSSDPayment = false;
      this.acceptBankTransfer = false;
    } else if (this.currency == FlutterwaveCurrency.GHS) {
      this.acceptGhanaPayment = true;
      this.acceptAccountPayment = false;
      this.acceptRwandaMoneyPayment = false;
      this.acceptMpesaPayment = false;
      this.acceptUgandaPayment = false;
      this.acceptFrancophoneMobileMoney = false;
      this.acceptUSSDPayment = false;
      this.acceptBankTransfer = false;
    } else if (this.currency == FlutterwaveCurrency.XAF ||
        this.currency == FlutterwaveCurrency.XOF) {
      this.acceptFrancophoneMobileMoney = true;
      this.acceptAccountPayment = false;
      this.acceptRwandaMoneyPayment = false;
      this.acceptMpesaPayment = false;
      this.acceptGhanaPayment = false;
      this.acceptUgandaPayment = false;
      this.acceptUSSDPayment = false;
      this.acceptBankTransfer = false;
    } else if (this.currency == FlutterwaveCurrency.ZAR) {
      this.acceptFrancophoneMobileMoney = false;
      this.acceptAccountPayment = false;
      this.acceptRwandaMoneyPayment = false;
      this.acceptMpesaPayment = false;
      this.acceptGhanaPayment = false;
      this.acceptUgandaPayment = false;
      this.acceptUSSDPayment = false;
      this.acceptBankTransfer = false;
    } else {
      this.acceptCardPayment = true;

      this.acceptAccountPayment = false;
      this.acceptRwandaMoneyPayment = false;
      this.acceptMpesaPayment = false;
      this.acceptGhanaPayment = false;
      this.acceptUgandaPayment = false;
      this.acceptUSSDPayment = false;
      this.acceptBankTransfer = false;
    }
  }

  String _setCountry() {
    switch (this.currency) {
      //TODO to be included once ACH payment is available on v3
      case FlutterwaveCurrency.ZAR:
        return "ZA";
      case FlutterwaveCurrency.NGN:
        return "NG";
      case FlutterwaveCurrency.GHS:
        return "GH";
      case FlutterwaveCurrency.RWF:
        return "RW";
      case FlutterwaveCurrency.UGX:
        return "UG";
      case FlutterwaveCurrency.ZMW:
        return "ZM";
      default:
        return "NG";
    }
  }

  /// Launches payment screen
  /// Returns a future ChargeResponse intance
  /// Nullable
  Future<ChargeResponse> initializeForUiPayments() async {
    FlutterwavePaymentManager paymentManager = FlutterwavePaymentManager(
        publicKey: this.publicKey,
        encryptionKey: this.encryptionKey,
        currency: this.currency,
        email: this.email,
        fullName: this.fullName,
        amount: this.amount,
        txRef: this.txRef,
        isDebugMode: this.isDebugMode,
        narration: this.narration,
        isPermanent: this.isPermanent,
        phoneNumber: this.phoneNumber,
        frequency: this.frequency,
        duration: this.duration,
        redirectUrl: this.redirectUrl,
        acceptAccountPayment: this.acceptAccountPayment,
        acceptCardPayment: this.acceptCardPayment,
        acceptUSSDPayment: this.acceptUSSDPayment,
        acceptRwandaMoneyPayment: this.acceptRwandaMoneyPayment,
        acceptMpesaPayment: this.acceptMpesaPayment,
        acceptZambiaPayment: this.acceptZambiaPayment,
        acceptGhanaPayment: this.acceptGhanaPayment,
        acceptUgandaPayment: this.acceptUgandaPayment,
        acceptBankTransferPayment: this.acceptBankTransfer,
        acceptFancophoneMobileMoney: this.acceptFrancophoneMobileMoney,
        country: this._setCountry());

    final chargeResponse = await this._launchPaymentScreen(paymentManager);
    return chargeResponse;
  }

  Future<ChargeResponse> _launchPaymentScreen(
      final FlutterwavePaymentManager paymentManager) async {
    return await Navigator.push(
      this.context,
      MaterialPageRoute(builder: (context) => FlutterwaveUI(paymentManager)),
    );
  }

  void _validateKeys() {
    if (this.encryptionKey.trim().isEmpty)
      throw FlutterWaveError("Encrytion key is required");
    if (this.publicKey.trim().isEmpty)
      throw FlutterWaveError("Public key is required");
    if (this.currency.trim().isEmpty)
      throw FlutterWaveError("Currency is required");
    if (this.amount.trim().isEmpty)
      throw FlutterWaveError("Amount is required");
    if (this.email.trim().isEmpty) throw FlutterWaveError("Email is required");
    if (this.fullName.trim().isEmpty)
      throw FlutterWaveError("Full Name is required");
    if (this.txRef.trim().isEmpty) throw FlutterWaveError("txRef is required");
    if (this.phoneNumber.trim().isEmpty)
      throw FlutterWaveError("Phone Number is required");
  }
}
