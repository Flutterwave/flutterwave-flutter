import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterwave/core/core_utils/flutterwave_api_utils.dart';
import 'package:flutterwave/core/metrics/metric_manager.dart';
import 'package:flutterwave/core/pay_with_account_manager/bank_account_manager.dart';
import 'package:flutterwave/models/bank.dart';
import 'package:flutterwave/models/requests/authorization.dart';
import 'package:flutterwave/models/requests/pay_with_bank_account/pay_with_bank_account.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/widgets/card_payment/authorization_webview.dart';
import 'package:flutterwave/widgets/card_payment/request_otp.dart';
import 'package:flutterwave/widgets/flutterwave_view_utils.dart';
import 'package:http/http.dart' as http;

class PayWithBankAccount extends StatefulWidget {
  final BankAccountPaymentManager _paymentManager;

  PayWithBankAccount(this._paymentManager);

  @override
  PayWithBankAccountState createState() => PayWithBankAccountState();
}

class PayWithBankAccountState extends State<PayWithBankAccount> {
  Bank? selectedBank;
  PersistentBottomSheetController? bottomSheet;
  Future<List<Bank>>? banks;

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _bankController = TextEditingController();

  BuildContext? _loadingDialogContext;

  @override
  void initState() {
    super.initState();
    this.banks = FlutterwaveAPIUtils.getBanks(http.Client(), this.widget._paymentManager.publicKey);
  }

  @override
  void dispose() {
    super.dispose();
    this._accountNumberController.dispose();
    this._phoneNumberController.dispose();
    this._bankController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(this.widget._paymentManager.phoneNumber);
    this._phoneNumberController.text = this.widget._paymentManager.phoneNumber;
    this._bankController.text =
        this.selectedBank != null ? this.selectedBank!.name! : "";
    return MaterialApp(
      debugShowCheckedModeBanner: widget._paymentManager.isDebugMode,
      home: Scaffold(
        key: this._scaffoldKey,
        appBar: FlutterwaveViewUtils.appBar(context, "Bank Account"),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Form(
              key: this._formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Phone Number",
                      labelText: "Phone Number",
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    controller: this._phoneNumberController,
                    validator: (value) =>
                    value != null && value.isEmpty ? "Phone Number is required" : null,
                  ),
                  TextFormField(
                    onTap: this._showBottomSheet,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Bank",
                      labelText: "Bank",
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    controller: this._bankController,
                    validator: (value) =>
                    value != null && value.isEmpty ? "Bank is required" : null,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Account Number",
                      labelText: "Account Number",
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                    controller: this._accountNumberController,
                    validator: (value) =>
                    value != null && value.isEmpty
                        ? "Account Number is required" : null,
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: ElevatedButton(
                      onPressed: this._onPaymentClicked,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          elevation: 0.5),
                      child: Text(
                        "PAY WITH ACCOUNT",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _banks() {
    return FutureBuilder(
        future: this.banks,
        builder: (BuildContext context, AsyncSnapshot<List<Bank>> snapshot) {
          if (snapshot.hasData) {
            return this._bankLists(snapshot.data!);
          }
          if (snapshot.hasError) {
            return Center(child: Text("Unable to fetch banks."));
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Widget _bankLists(final List<Bank> banks) {
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
                        bank.name!,
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

  void _onPaymentClicked() {
    if (this._formKey.currentState!.validate()) {
      final BankAccountPaymentManager pm = this.widget._paymentManager;
      final String updatedPhoneNumber = this._phoneNumberController.text.trim();
      if (updatedPhoneNumber.isNotEmpty) {
        pm.phoneNumber = this._phoneNumberController.text.trim();
      }
      FlutterwaveViewUtils.showConfirmPaymentModal(
          this.context, pm.currency, pm.amount, this._payWithBankAccount);
    }
  }

  void _payWithBankAccount() async {
    Navigator.pop(this.context);

    this._showLoading(FlutterwaveConstants.INITIATING_PAYMENT);

    final BankAccountPaymentRequest request = BankAccountPaymentRequest(
        amount: this.widget._paymentManager.amount,
        currency: this.widget._paymentManager.currency,
        email: this.widget._paymentManager.email,
        fullName: this.widget._paymentManager.fullName,
        txRef: this.widget._paymentManager.txRef,
        phoneNumber: this._phoneNumberController.text.trim(),
        accountBank: this.selectedBank!.code!,
        accountNumber: this._accountNumberController.text.trim());

    final response = await this
        .widget
        ._paymentManager
        .payWithAccount(request, http.Client());
    this._closeDialog();
    this._handleResponse(response);
  }

  void _handleResponse(final ChargeResponse response) {
    if (response.data == null ||
        response.status == FlutterwaveConstants.ERROR) {
      this._showSnackBar(response.message!);
      return;
    }

    if (response.data!.status == FlutterwaveConstants.SUCCESSFUL &&
        response.data!.processorResponse ==
            FlutterwaveConstants.APPROVED_SUCCESSFULLY) {
      this._verifyPayment(response);
      return;
    }

    if (response.data!.processorResponse ==
        FlutterwaveConstants.PENDING_OTP_VALIDATION) {
      this._handleOtp(response);
      return;
    }

    if (response.meta != null &&
        response.meta!.authorization != null &&
        response.data!.status == FlutterwaveConstants.PENDING) {
      this._handleExtraAuthentication(response);
      return;
    }
    this._closeDialog();

    if ((response.data!.status == FlutterwaveConstants.PENDING) &&
        (response.data!.authUrl != null) &&
        response.data!.authUrl!.isNotEmpty) {
      this._handleWebAuthorisation(response);
    }

    if ((response.data!.status == FlutterwaveConstants.PENDING) &&
        (response.meta == null ||
            response.meta!.authorization == null ||
            response.meta!.authorization!.mode == null)) {
      this._showSnackBar(
          "Unable to complete payment with this account. Please try later.");
      return;
    }
    final errorMessage = response.message == null
        ? "Unable to continue payment with account"
        : response.message;
    this._closeDialog();
    print("response is ${response.toJson()}");
    this._showSnackBar(errorMessage!);
  }

  void _handleExtraAuthentication(ChargeResponse response) async {
    if (response.meta != null &&
        response.meta!.authorization != null &&
        response.meta!.authorization!.mode != null) {
      final String authMode = response.meta!.authorization!.mode;
      switch (authMode) {
        case Authorization.OTP:
          {
            this._handleOtp(response);
            break;
          }
        case Authorization.REDIRECT:
          {
            this._handleRedirect(response);
            break;
          }
      }
    } else {
      this._closeDialog();
      this._showSnackBar(
          "Unable to authenticate payment. Please contact support.");
    }
  }

  void _verifyPayment(ChargeResponse chargeResponse) async {
    final timeoutInMinutes = 4;
    final timeOutInSeconds = timeoutInMinutes * 60;
    final requestIntervalInSeconds = 7;
    final numberOfTries = timeOutInSeconds / requestIntervalInSeconds;
    int intialCount = 0;

    ChargeResponse? response;
    this._showLoading(FlutterwaveConstants.VERIFYING);

    Timer.periodic(Duration(seconds: requestIntervalInSeconds), (timer) async {
      if (intialCount >= numberOfTries && response != null) {
        timer.cancel();
        return this._onPaymentComplete(response!);
      }
      final client = http.Client();
      try {
        response = await FlutterwaveAPIUtils.verifyPayment(
            chargeResponse.data!.flwRef!,
            client,
            this.widget._paymentManager.publicKey,
            this.widget._paymentManager.isDebugMode,
            MetricManager.ACCOUNT_CHARGE_VERIFY);
        if ((response!.data!.status == FlutterwaveConstants.SUCCESSFUL ||
                response!.data!.status == FlutterwaveConstants.SUCCESS) &&
            response!.data!.amount == this.widget._paymentManager.amount &&
            response!.data!.flwRef == chargeResponse.data!.flwRef) {
          timer.cancel();
          this._onPaymentComplete(response!);
        } else {
          if (!timer.isActive) this._showSnackBar(response!.message!);
        }
      } catch (error) {
        timer.cancel();
        this._closeDialog();
        this._showSnackBar(error.toString());
      } finally {
        intialCount = intialCount + 1;
      }
    });
    return;
  }

  void _handleOtp(final ChargeResponse response) async {
    this._closeDialog();
    String message;
    if (response.meta != null &&
        response.meta!.authorization != null &&
        response.meta!.authorization!.validateInstructions != null) {
      message = response.meta!.authorization!.validateInstructions!;
    } else {
      message = "Please validate with the OTP sent to your mobile or email";
    }
    final otp = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => RequestOTP(message)));
    if (otp == null) {
      this._showSnackBar("Transaction cancelled.");
      return;
    }
    this._validatePayment(otp, response.data!.flwRef!);
  }

  void _handleRedirect(ChargeResponse response) async {
    this._closeDialog();
    final url = response.meta!.authorization!.redirect;
    if (url == null || url.isEmpty) {
      this._showSnackBar("Unable to redirect to complete payment.");
      return;
    }
    final flw = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AuthorizationWebview(
            Uri.encodeFull(url), this.widget._paymentManager.redirectUrl!)));
    if (response == null) {
      this._showSnackBar("Transaction cancelled.");
      return;
    }
    this._verifyPayment(flw);
  }

  void _validatePayment(final String otp, final String flwRef) async {
    this._showLoading(FlutterwaveConstants.VALIDATING_OTP);
    final client = http.Client();
    final response = await FlutterwaveAPIUtils.validatePayment(
        otp,
        flwRef,
        client,
        this.widget._paymentManager.isDebugMode,
        this.widget._paymentManager.publicKey,
        true,
        MetricManager.ACCOUNT_CHARGE_VALIDATE);
    this._closeDialog();
    if (response.status == FlutterwaveConstants.SUCCESS &&
        response.message == FlutterwaveConstants.CHARGE_VALIDATED) {
      this._verifyPayment(response);
    } else {
      this._showSnackBar(response.message!);
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: this.context,
      builder: (context) {
        return this._banks();
      },
    );
  }

  void _handleBankTap(final Bank selectedBank) {
    this._removeFocusFromView();
    this.setState(() {
      this.selectedBank = selectedBank;
    });
    Navigator.pop(this.context);
  }

  void _removeFocusFromView() {
    FocusScope.of(this.context).requestFocus(FocusNode());
  }

  void _showSnackBar(String message) {
    final text = message == null
        ? "Unable to complete payment. Please contact support"
        : message;
    SnackBar snackBar = SnackBar(
      content: Text(
        text,
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
        this._loadingDialogContext = context;
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
    if (this._loadingDialogContext != null) {
      Navigator.of(this._loadingDialogContext!).pop();
      this._loadingDialogContext = null;
    }
  }

  void _onPaymentComplete(final ChargeResponse chargeResponse) {
    this._closeDialog();
    Navigator.pop(this.context, chargeResponse);
  }

  void _handleWebAuthorisation(ChargeResponse response) async {
    final String result = await Navigator.push(
        this.context,
        MaterialPageRoute(
            builder: (context) => AuthorizationWebview(
                Uri.encodeFull(response.data!.authUrl!),
                this.widget._paymentManager.redirectUrl!)));
    if (result != null) {
      this._verifyPayment(response);
    }
  }
}
