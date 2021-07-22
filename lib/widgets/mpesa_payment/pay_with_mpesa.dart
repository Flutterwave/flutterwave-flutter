import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterwave/core/core_utils/flutterwave_api_utils.dart';
import 'package:flutterwave/core/mpesa/mpesa_payment_manager.dart';
import 'package:flutterwave/models/requests/mpesa/mpesa_request.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/widgets/flutterwave_view_utils.dart';
import 'package:http/http.dart' as http;

class PayWithMpesa extends StatefulWidget {
  final MpesaPaymentManager _paymentManager;

  PayWithMpesa(this._paymentManager);

  @override
  _PayWithMpesaState createState() => _PayWithMpesaState();
}

class _PayWithMpesaState extends State<PayWithMpesa> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController networkController = TextEditingController();
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
        appBar: FlutterwaveViewUtils.appBar(context, "Mpesa"),
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
                    validator: (value) =>
                        value != null && value.isEmpty ? "Phone number is required" : null,
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                    child: ElevatedButton(
                      onPressed: this._onPayPressed,
                      style: ElevatedButton.styleFrom(primary: Colors.orange),
                      child: Text(
                        "Pay with Mpesa",
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

  void _onPayPressed() {
    if (this._formKey.currentState!.validate()) {
      this._removeFocusFromView();
      if (this._phoneNumberController.text.isNotEmpty) {
        this.widget._paymentManager.phoneNumber =
            this._phoneNumberController.text;
      }
      final MpesaPaymentManager pm = this.widget._paymentManager;
      FlutterwaveViewUtils.showConfirmPaymentModal(
          this.context, pm.currency, pm.amount, this._handlePayment);
    }
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

  void _removeFocusFromView() {
    FocusScope.of(this.context).requestFocus(FocusNode());
  }

  void _showSnackBar(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
    this._scaffoldKey.currentState!.showSnackBar(snackBar);
  }

  void _handlePayment() async {
    Navigator.pop(this.context);

    this._showLoading(FlutterwaveConstants.INITIATING_PAYMENT);
    final MpesaPaymentManager mpesaPaymentManager = this.widget._paymentManager;

    final MpesaRequest request = MpesaRequest(
        amount: mpesaPaymentManager.amount,
        currency: mpesaPaymentManager.currency,
        txRef: mpesaPaymentManager.txRef,
        fullName: mpesaPaymentManager.fullName,
        email: mpesaPaymentManager.email,
        phoneNumber: this._phoneNumberController.text);

    final http.Client client = http.Client();
    try {
      final response = await mpesaPaymentManager.payWithMpesa(request, client);
      this._closeDialog();
      if (FlutterwaveConstants.SUCCESS == response.status &&
          FlutterwaveConstants.CHARGE_INITIATED == response.message) {
        this._verifyPayment(response);
      } else {
        this._showSnackBar(response.message!);
      }
    } catch (error) {
      this._closeDialog();
      this._showSnackBar(error.toString());
    }
  }

  void _verifyPayment(final ChargeResponse chargeResponse) async {
    final timeoutInMinutes = 3;
    final timeOutInSeconds = timeoutInMinutes * 60;
    final requestIntervalInSeconds = 7;
    final numberOfTries = timeOutInSeconds / requestIntervalInSeconds;
    int intialCount = 0;

    ChargeResponse? response;

    this._showLoading(FlutterwaveConstants.VERIFYING);
    final client = http.Client();
    Timer.periodic(Duration(seconds: requestIntervalInSeconds), (timer) async {
      try {
        if (intialCount == numberOfTries) {
          timer.cancel();
          return this._onComplete(response!);
        }
        response = await FlutterwaveAPIUtils.verifyPayment(
            chargeResponse.data!.flwRef!,
            client,
            this.widget._paymentManager.publicKey,
            this.widget._paymentManager.isDebugMode);

        if ((response!.data!.status == FlutterwaveConstants.SUCCESS ||
                response!.data!.status == FlutterwaveConstants.SUCCESSFUL) &&
            response!.data!.amount ==
                this.widget._paymentManager.amount.toString() &&
            response!.data!.flwRef == chargeResponse.data!.flwRef &&
            response!.data!.currency == this.widget._paymentManager.currency) {
          timer.cancel();
          this._onComplete(response!);
        } else {
          if (!timer.isActive) {
            this._closeDialog();
            this._showSnackBar(response!.message!);
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
