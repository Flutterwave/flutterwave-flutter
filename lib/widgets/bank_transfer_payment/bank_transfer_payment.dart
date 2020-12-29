import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterwave/core/bank_transfer_manager/bank_transfer_payment_manager.dart';
import 'package:flutterwave/core/core_utils/flutterwave_api_utils.dart';
import 'package:flutterwave/models/requests/bank_transfer/bank_transfer_request.dart';
import 'package:flutterwave/models/responses/bank_transfer_response/bank_transfer_response.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/widgets/flutterwave_view_utils.dart';
import 'package:http/http.dart' as http;

import 'pay_with_account_button.dart';
import 'show_transfer_details.dart';

class PayWithBankTransfer extends StatefulWidget {
  final BankTransferPaymentManager _paymentManager;

  PayWithBankTransfer(this._paymentManager);

  @override
  _PayWithBankTransferState createState() => _PayWithBankTransferState();
}

class _PayWithBankTransferState extends State<PayWithBankTransfer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  BuildContext loadingDialogContext;

  BankTransferResponse _bankTransferResponse;
  bool hasInitiatedPay = false;
  bool hasVerifiedPay = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: widget._paymentManager.isDebugMode,
      home: Scaffold(
          key: this._scaffoldKey,
          appBar: AppBar(
            backgroundColor: Color(0xFFfff1d0),
            title: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                text: "Pay with ",
                style: TextStyle(fontSize: 17, color: Colors.black),
                children: [
                  TextSpan(
                    text: "Bank Transfer",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  )
                ],
              ),
            ),
            leading: BackButton(
              color: Colors.black,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                  margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  width: double.infinity,
                  child: this._getHomeView()))),
    );
  }

  Widget _getHomeView() {
    return this.hasInitiatedPay
        ? AccountDetails(this._bankTransferResponse, this._verifyTransfer)
        : PayWithTransferButton(this._onPayClicked);
  }

  void _onPayClicked() {
    final BankTransferPaymentManager pm = this.widget._paymentManager;
    FlutterwaveViewUtils.showConfirmPaymentModal(
        this.context, pm.currency, pm.amount, this._initiateBankTransfer);
  }

  void _initiateBankTransfer() async {
    Navigator.pop(this.context);

    this._showLoading(FlutterwaveConstants.INITIATING_PAYMENT);
    final http.Client client = http.Client();
    final BankTransferRequest request = BankTransferRequest(
        amount: this.widget._paymentManager.amount,
        currency: this.widget._paymentManager.currency,
        duration: this.widget._paymentManager.duration.toString(),
        email: this.widget._paymentManager.email,
        frequency: this.widget._paymentManager.frequency.toString(),
        isPermanent: this.widget._paymentManager.isPermanent.toString(),
        narration: this.widget._paymentManager.narration,
        phoneNumber: this.widget._paymentManager.phoneNumber,
        txRef: this.widget._paymentManager.txRef);

    try {
      final BankTransferResponse response = await this
          .widget
          ._paymentManager
          .payWithBankTransfer(request, client);
      if (FlutterwaveConstants.SUCCESS == response.status) {
        this._afterChargeInitiated(response);
      } else {
        this._closeDialog();
        this._showSnackBar(response.message);
      }
    } catch (error) {
      this._showSnackBar(error.toString());
    } finally {
      this._closeDialog();
    }
  }

  void _verifyTransfer() async {
    if (this._bankTransferResponse != null) {
      final timeoutInMinutes = 2;
      final timeOutInSeconds = timeoutInMinutes * 60;
      final requestIntervalInSeconds = 15;
      final numberOfTries = timeOutInSeconds / requestIntervalInSeconds;
      int intialCount = 0;

      final BankTransferPaymentManager pm = this.widget._paymentManager;

      this._showLoading(FlutterwaveConstants.VERIFYING);
      ChargeResponse response;
      Timer.periodic(Duration(seconds: requestIntervalInSeconds),
          (timer) async {
        final client = http.Client();
        if ((intialCount >= numberOfTries) && response != null) {
          timer.cancel();
          this._closeDialog();
          this._onPaymentComplete(response);
        }
        try {
          response = await FlutterwaveAPIUtils.verifyPayment(
              this._bankTransferResponse.meta.authorization.transferReference,
              client,
              this.widget._paymentManager.publicKey,
              this.widget._paymentManager.isDebugMode);

          if (response.data.status == FlutterwaveConstants.SUCCESS &&
              response.data.amount == pm.amount &&
              response.data.currency == pm.currency &&
              response.data.flwRef ==
                  this
                      ._bankTransferResponse
                      .meta
                      .authorization
                      .transferReference
                      .toString()) {
            this._closeDialog();
            this._showSnackBar("Payment received");
            timer.cancel();
            this._onPaymentComplete(response);
          } else {
            print("inside else, response is ${response.toJson()}");
          }
        } catch (error) {
          timer.cancel();
          this._closeDialog();
          this._showSnackBar(error.toString());
        } finally {
          intialCount = intialCount + 1;
        }
      });
    } else {
      this._showSnackBar("An unexpected error ocurred.");
    }
  }

  void _afterChargeInitiated(BankTransferResponse response) {
    this.setState(() {
      this._bankTransferResponse = response;
      this.hasInitiatedPay = true;
    });
  }

  void _showSnackBar(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
    this._scaffoldKey.currentState.showSnackBar(snackBar);
  }

  void _onPaymentComplete(final ChargeResponse chargeResponse) {
    this._showSnackBar("Transaction completed.");
    Navigator.pop(this.context, chargeResponse);
  }

  Future<void> _showLoading(String message) {
    return showDialog(
      context: this.context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        this.loadingDialogContext = context;
        return AlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(
                backgroundColor: Colors.orangeAccent,
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
      Navigator.of(this.loadingDialogContext).pop();
      this.loadingDialogContext = null;
    }
  }
}
