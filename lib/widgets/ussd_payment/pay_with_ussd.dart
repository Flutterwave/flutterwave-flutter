import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterwave/core/core_utils/flutterwave_api_utils.dart';
import 'package:flutterwave/core/ussd_payment_manager/ussd_manager.dart';
import 'package:flutterwave/models/bank_with_ussd.dart';
import 'package:flutterwave/models/requests/ussd/ussd_request.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/widgets/flutterwave_view_utils.dart';
import 'package:flutterwave/widgets/ussd_payment/pay_with_ussd_button.dart';
import 'package:flutterwave/widgets/ussd_payment/ussd_details.dart';
import 'package:http/http.dart' as http;

class PayWithUssd extends StatefulWidget {
  final USSDPaymentManager _paymentManager;

  PayWithUssd(this._paymentManager);

  @override
  _PayWithUssdState createState() => _PayWithUssdState();
}

class _PayWithUssdState extends State<PayWithUssd> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  BuildContext? loadingDialogContext;
  TextEditingController controller = TextEditingController();

  ChargeResponse? _chargeResponse;
  bool hasInitiatedPay = false;
  bool hasVerifiedPay = false;
  bool isBottomSheetOpen = false;

  final FocusNode focusNode = FocusNode();
  BanksWithUssd? selectedBank;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: widget._paymentManager.isDebugMode,
      home: Scaffold(
        key: this._scaffoldKey,
        appBar: FlutterwaveViewUtils.appBar(context, "USSD"),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
            width: double.infinity,
            child: this._getHomeView(),
          ),
        ),
      ),
    );
  }

  Widget _getHomeView() {
    return this.hasInitiatedPay
        ? USSDDetails(this._chargeResponse!, this._verifyTransfer)
        : PayWithUssdButton(
            this._initiateUSSDPayment, this.controller, this._showBottomSheet);
  }

  Widget _getBanksThatAllowsUssd() {
    final banks = BanksWithUssd.getBanks();
    return Container(
      height: 250,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: Colors.white,
      child: ListView(
        children: banks
            .map((bank) => ListTile(
                  onTap: () => {this._handleBankTap(bank)},
                  title: Column(
                    children: [
                      Text(
                        bank.bankName,
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 4),
                      Divider(height: 1)
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  void _handleBankTap(final BanksWithUssd selectedBank) {
    this._removeFocusFromView();
    this.setState(() {
      this.selectedBank = selectedBank;
      this.controller.text = selectedBank.bankName;
    });
    Navigator.pop(this.context);
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: this.context,
        builder: (context) {
          return this._getBanksThatAllowsUssd();
        });
    this.setState(() {
      this.isBottomSheetOpen = true;
    });
  }

  void _removeFocusFromView() {
    FocusScope.of(this.context).requestFocus(FocusNode());
  }

  void _initiateUSSDPayment() async {
    if (this.selectedBank != null) {
      final USSDPaymentManager pm = this.widget._paymentManager;
     FlutterwaveViewUtils.showConfirmPaymentModal(this.context,
         pm.currency, pm.amount, this._payWithUSSD);
    } else {
      this._showSnackBar("Please select a bank");
    }
  }

  void _payWithUSSD() async {
    Navigator.pop(this.context);

    this._showLoading(FlutterwaveConstants.INITIATING_PAYMENT);
    final USSDPaymentManager ussdPaymentManager = this.widget._paymentManager;
    final request = USSDRequest(
        amount: ussdPaymentManager.amount,
        currency: ussdPaymentManager.currency,
        email: ussdPaymentManager.email,
        txRef: ussdPaymentManager.txRef,
        fullName: ussdPaymentManager.fullName,
        accountBank: this.selectedBank!.bankCode,
        phoneNumber: ussdPaymentManager.phoneNumber);

    try {
      final ChargeResponse response = await this
          .widget
          ._paymentManager
          .payWithUSSD(request, http.Client());
      if (FlutterwaveConstants.SUCCESS == response.status) {
        this._afterChargeInitiated(response);
      } else {
        this._showSnackBar(response.message!);
      }
    } catch (error) {
      this._showSnackBar(error.toString());
    } finally {
      this._closeDialog();
    }
  }

  void _verifyTransfer() async {
    final timeoutInMinutes = 2;
    final timeOutInSeconds = timeoutInMinutes * 60;
    final requestIntervalInSeconds = 7;
    final numberOfTries = timeOutInSeconds/requestIntervalInSeconds;
    int intialCount = 0;

    if (this._chargeResponse != null) {
      this._showLoading(FlutterwaveConstants.VERIFYING);
      final client = http.Client();
      ChargeResponse? response;
      Timer.periodic(Duration(seconds: requestIntervalInSeconds), (timer) async {
        try {
          if ((intialCount >= numberOfTries) && response != null) {
            timer.cancel();
            this._closeDialog();
            this._onComplete(response!);
          }
          response = await FlutterwaveAPIUtils.verifyPayment(
              this._chargeResponse!.data!.flwRef!,
              client,
              this.widget._paymentManager.publicKey,
              this.widget._paymentManager.isDebugMode);

          if (response!.data!.status == FlutterwaveConstants.SUCCESSFUL &&
              this._chargeResponse!.data!.flwRef == response!.data!.flwRef &&
              response!.data!.amount ==
                  this._chargeResponse!.data!.amount.toString()) {
            timer.cancel();
            this._closeDialog();
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
  }

  void _onComplete(final ChargeResponse chargeResponse) {
    this._showSnackBar("Payment Completed");
    Navigator.pop(this.context, chargeResponse);
  }

  void _afterChargeInitiated(ChargeResponse response) {
    this.setState(() {
      this._chargeResponse = response;
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
    ScaffoldMessenger.maybeOf(this._scaffoldKey.currentContext!)?.showSnackBar(
        snackBar);
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
}

