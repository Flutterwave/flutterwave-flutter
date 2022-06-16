import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterwave/core/core_utils/flutterwave_api_utils.dart';
import 'package:flutterwave/core/voucher_payment/voucher_payment_manager.dart';
import 'package:flutterwave/models/requests/voucher/voucher_payment_request.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/widgets/flutterwave_view_utils.dart';
import 'package:http/http.dart' as http;

class PayWithVoucher extends StatefulWidget {
  final VoucherPaymentManager _paymentManager;

  PayWithVoucher(this._paymentManager);

  @override
  _PayWithVoucherState createState() => _PayWithVoucherState();
}

class _PayWithVoucherState extends State<PayWithVoucher> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _voucherPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  BuildContext? loadingDialogContext;

  @override
  Widget build(BuildContext context) {
    final String initialPhoneNumber = this.widget._paymentManager.phoneNumber;
    this._phoneNumberController.text =
        initialPhoneNumber != null ? initialPhoneNumber : "";

    return MaterialApp(
      debugShowCheckedModeBanner: widget._paymentManager.isDebugMode,
      home: Scaffold(
        key: this._scaffoldKey,
        appBar: FlutterwaveViewUtils.appBar(context, "voucher"),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 35, 20, 20),
            width: double.infinity,
            child: Form(
              key: this._formKey,
              child: ListView(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "Phone Number",
                    ),
                    controller: this._phoneNumberController,
                    validator: (value) => value != null && value.isEmpty
                        ? "phone number is required"
                        : null,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: "Voucher Pin",
                      hintText: "Voucher Pin",
                    ),
                    controller: this._voucherPinController,
                    validator: (value) => value != null && value.isEmpty
                        ? "voucher pin is required"
                        : null,
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                    child: RaisedButton(
                      onPressed: this._onPayPressed,
                      color: Colors.orange,
                      child: Text(
                        "Pay with Voucher",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showLoading(String message) {
    return showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        this.loadingDialogContext = context;
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                backgroundColor: Colors.orangeAccent,
              ),
              SizedBox(
                width: 40,
              ),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black),
              )
            ],
          ),
        );
      },
    );
  }

  void _closeDialog() {
    if (this.loadingDialogContext != null) {
      Navigator.of(this.loadingDialogContext!).pop();
      this.loadingDialogContext = null;
    }
  }

  void _showSnackBar(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
    this._scaffoldKey.currentState?.showSnackBar(snackBar);
  }

  void _onPayPressed() {
    if (this._formKey.currentState!.validate()) {
      final VoucherPaymentManager paymentManager = this.widget._paymentManager;
      FlutterwaveViewUtils.showConfirmPaymentModal(
          this.context,
          paymentManager.currency,
          paymentManager.amount,
          this._initiatePayment);
    }
  }

  void _initiatePayment() async {
    Navigator.pop(this.context);
    this._showLoading(FlutterwaveConstants.INITIATING_PAYMENT);

    final VoucherPaymentManager paymentManager = this.widget._paymentManager;
    final VoucherPaymentRequest request = VoucherPaymentRequest(
        amount: paymentManager.amount,
        currency: paymentManager.currency,
        email: paymentManager.email,
        txRef: paymentManager.txRef,
        fullName: paymentManager.fullName,
        phoneNumber: paymentManager.phoneNumber,
        pin: this._voucherPinController.text.toString());
    try {
      final http.Client client = http.Client();
      final response = await paymentManager.payWithVoucher(request, client);
      this._closeDialog();

      if (FlutterwaveConstants.SUCCESS == response.status &&
          FlutterwaveConstants.CHARGE_INITIATED == response.message) {
        this._verifyPayment(response);
      } else {
        this._showSnackBar(response.message!);
      }
    } catch (error) {
      this._closeDialog();
    }
  }

  void _verifyPayment(final ChargeResponse chargeResponse) async {
    final timeoutInMinutes = 2;
    final timeOutInSeconds = timeoutInMinutes * 60;
    final requestIntervalInSeconds = 7;
    final numberOfTries = timeOutInSeconds / requestIntervalInSeconds;
    int intialCount = 0;

    this._showLoading(FlutterwaveConstants.VERIFYING);
    Timer.periodic(Duration(seconds: requestIntervalInSeconds), (timer) async {
      if (intialCount == numberOfTries) {
        timer.cancel();
      }
      final client = http.Client();
      try {
        final response = await FlutterwaveAPIUtils.verifyPayment(
            chargeResponse.data!.flwRef!,
            client,
            this.widget._paymentManager.publicKey,
            this.widget._paymentManager.isDebugMode);
        this._closeDialog();
        if ((response.data!.status == FlutterwaveConstants.SUCCESSFUL ||
                response.data!.status == FlutterwaveConstants.SUCCESS) &&
            response.data!.amount == this.widget._paymentManager.amount &&
            response.data!.flwRef == chargeResponse.data!.flwRef) {
          timer.cancel();
          this._onComplete(response);
        } else {
          if (!timer.isActive) {
            this._closeDialog();
            this._showSnackBar(response.message!);
          }
        }
      } catch (error) {
        timer.cancel();
        this._closeDialog();
        this._showSnackBar(error.toString());
      } finally {
        intialCount = intialCount + 1;
      }
    });
  }

  void _onComplete(final ChargeResponse chargeResponse) {
    this._closeDialog();
    Navigator.pop(this.context, chargeResponse);
  }
}
