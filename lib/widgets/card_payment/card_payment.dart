import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterwave/core/card_payment_manager/card_payment_manager.dart';
import 'package:flutterwave/core/core_utils/flutterwave_api_utils.dart';
import 'package:flutterwave/core/metrics/metric_manager.dart';
import 'package:flutterwave/interfaces/card_payment_listener.dart';
import 'package:flutterwave/models/requests/charge_card/charge_card_request.dart';
import 'package:flutterwave/models/requests/charge_card/charge_request_address.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/widgets/card_payment/authorization_webview.dart';
import 'package:flutterwave/widgets/card_payment/request_address.dart';
import 'package:flutterwave/widgets/flutterwave_view_utils.dart';
import 'package:http/http.dart' as http;

import 'request_otp.dart';
import 'request_pin.dart';

class CardPayment extends StatefulWidget {
  final CardPaymentManager _paymentManager;

  CardPayment(this._paymentManager);

  @override
  _CardPaymentState createState() => _CardPaymentState();
}

class _CardPaymentState extends State<CardPayment>
    implements CardPaymentListener {
  final _cardFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BuildContext? loadingDialogContext;

  final TextEditingController _cardNumberFieldController =
      TextEditingController();
  final TextEditingController _cardMonthFieldController =
      TextEditingController();
  final TextEditingController _cardYearFieldController =
      TextEditingController();
  final TextEditingController _cardCvvFieldController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    this._cardMonthFieldController.dispose();
    this._cardYearFieldController.dispose();
    this._cardCvvFieldController.dispose();
    this._cardNumberFieldController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: widget._paymentManager.isDebugMode,
      home: Scaffold(
        key: this._scaffoldKey,
        appBar: FlutterwaveViewUtils.appBar(context, "Card"),
        body: Form(
          key: this._cardFormKey,
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 30, 10, 10),
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  child: Text(
                    "Enter your card details",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
                  width: double.infinity,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: "Card Number",
                      labelText: "Card Number",
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    controller: this._cardNumberFieldController,
                    validator: this._validateCardField,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 7,
                      margin: EdgeInsets.fromLTRB(30, 5, 30, 5),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "MM",
                          labelText: "Month",
                          counterText: "",
                        ),
                        maxLength: 2,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        ),
                        controller: this._cardMonthFieldController,
                        validator: this._validateCardField,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 7,
                      margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "YY",
                          labelText: "Year",
                          counterText: "",
                        ),
                        maxLength: 2,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        ),
                        controller: this._cardYearFieldController,
                        validator: this._validateCardField,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 7,
                      margin: EdgeInsets.fromLTRB(40, 5, 40, 5),
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: "cvv",
                          labelText: "cvv",
                          counterText: "",
                        ),
                        maxLength: 3,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        autocorrect: false,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                        ),
                        controller: this._cardCvvFieldController,
                        validator: (value) => value != null && value.isEmpty
                            ? "cvv is required"
                            : null,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 45,
                  margin: EdgeInsets.fromLTRB(40, 20, 20, 40),
                  child: RaisedButton(
                    onPressed: this._onCardFormClick,
                    color: Colors.orangeAccent,
                    child: Text(
                      "PAY",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onCardFormClick() {
    this._hideKeyboard();
    if (this._cardFormKey.currentState!.validate()) {
      final CardPaymentManager pm = this.widget._paymentManager;
      FlutterwaveViewUtils.showConfirmPaymentModal(
          this.context, pm.currency, pm.amount, this._makeCardPayment);
    }
  }

  void _makeCardPayment() {
    // Navigator.of(this.context).pop();
    this._showLoading(FlutterwaveConstants.INITIATING_PAYMENT);

    final ChargeCardRequest chargeCardRequest = ChargeCardRequest(
        cardNumber: this
            ._cardNumberFieldController
            .value
            .text
            .trim()
            .replaceAll(new RegExp(r"\s+"), ""),
        cvv: this._cardCvvFieldController.value.text.trim(),
        expiryMonth: this._cardMonthFieldController.value.text.trim(),
        expiryYear: this._cardYearFieldController.value.text.trim(),
        currency: this.widget._paymentManager.currency.trim(),
        amount: this.widget._paymentManager.amount.trim(),
        email: this.widget._paymentManager.email.trim(),
        fullName: this.widget._paymentManager.fullName.trim(),
        txRef: this.widget._paymentManager.txRef.trim(),
        redirectUrl: this.widget._paymentManager.redirectUrl,
        country: this.widget._paymentManager.country);

    final client = http.Client();

    this
        .widget
        ._paymentManager
        .setCardPaymentListener(this)
        .payWithCard(client, chargeCardRequest);
  }

  String? _validateCardField(String? value) {
    return value != null && value.trim().isEmpty ? "Please fill this" : null;
  }

  void _hideKeyboard() {
    FocusScope.of(this.context).requestFocus(FocusNode());
  }

  @override
  void onRedirect(ChargeResponse chargeResponse, String url) async {
    this._closeDialog();
    final result = await Navigator.of(this.context).push(MaterialPageRoute(
        builder: (context) => AuthorizationWebview(
            Uri.encodeFull(url), this.widget._paymentManager.redirectUrl!)));
    if (result != null) {
      final bool hasError = result.runtimeType != " ".runtimeType;
      this._closeDialog();
      if (hasError) {
        this._showSnackBar(result["error"]);
        return;
      }
      final flwRef = result;
      this._showLoading(FlutterwaveConstants.VERIFYING);
      final response = await FlutterwaveAPIUtils.verifyPayment(
          flwRef,
          http.Client(),
          this.widget._paymentManager.publicKey,
          this.widget._paymentManager.isDebugMode,
          MetricManager.VERIFY_CARD_CHARGE);
      this._closeDialog();
      if (response.data!.status == FlutterwaveConstants.SUCCESSFUL ||
          response.data!.status == FlutterwaveConstants.SUCCESS) {
        this.onComplete(response);
      }
    } else {
      this._showSnackBar("Transaction cancelled");
    }
  }

  @override
  void onRequireAddress(ChargeResponse response) async {
    this._closeDialog();
    final ChargeRequestAddress addressDetails = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RequestAddress()));
    if (addressDetails != null) {
      this._showLoading(FlutterwaveConstants.VERIFYING_ADDRESS);
      this.widget._paymentManager.addAddress(addressDetails);
      return;
    }
    this._closeDialog();
  }

  @override
  void onRequirePin(ChargeResponse response) async {
    this._closeDialog();
    final pin = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RequestPin()));
    if (pin == null) return;
    this._showLoading(FlutterwaveConstants.AUTHENTICATING_PIN);
    this.widget._paymentManager.addPin(pin);
  }

  @override
  void onRequireOTP(ChargeResponse response, String message) async {
    this._closeDialog();
    final otp = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RequestOTP(message)));
    if (otp == null) return;
    this._showLoading(FlutterwaveConstants.VERIFYING);
    final ChargeResponse chargeResponse =
        await this.widget._paymentManager.addOTP(otp, response.data!.flwRef!);
    this._closeDialog();
    if (chargeResponse.message == FlutterwaveConstants.CHARGE_VALIDATED) {
      this._showLoading(FlutterwaveConstants.VERIFYING);
      this._handleTransactionVerification(chargeResponse);
    } else {
      this._closeDialog();
      this._showSnackBar(chargeResponse.message!);
    }
  }

  void _handleTransactionVerification(
      final ChargeResponse chargeResponse) async {
    final verifyResponse = await FlutterwaveAPIUtils.verifyPayment(
        chargeResponse.data!.flwRef!,
        http.Client(),
        this.widget._paymentManager.publicKey,
        this.widget._paymentManager.isDebugMode,
        MetricManager.VERIFY_CARD_CHARGE);
    this._closeDialog();

    if ((verifyResponse.data!.status == FlutterwaveConstants.SUCCESS ||
            verifyResponse.data!.status == FlutterwaveConstants.SUCCESSFUL) &&
        verifyResponse.data!.txRef == this.widget._paymentManager.txRef &&
        verifyResponse.data!.amount == this.widget._paymentManager.amount) {
      this.onComplete(verifyResponse);
    } else {
      this._showSnackBar(verifyResponse.message!);
    }
  }

  @override
  void onError(String error) {
    if (this.loadingDialogContext == null) {
      Navigator.pop(context);
    } else {
      this._closeDialog();
    }
    this._showSnackBar(error);
  }

  @override
  void onNoAuthRequired(ChargeResponse chargeResponse) {
    this._closeDialog();
    this._handleTransactionVerification(chargeResponse);
  }

  @override
  void onComplete(ChargeResponse chargeResponse) {
    Navigator.pop(this.context, chargeResponse);
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
      Navigator.of(this.loadingDialogContext!).pop();
      this.loadingDialogContext = null;
    }
  }
}
