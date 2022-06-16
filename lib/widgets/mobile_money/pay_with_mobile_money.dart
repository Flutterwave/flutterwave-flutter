import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterwave/core/core_utils/flutterwave_api_utils.dart';
import 'package:flutterwave/core/mobile_money/mobile_money_payment_manager.dart';
import 'package:flutterwave/models/francophone_country.dart';
import 'package:flutterwave/models/requests/authorization.dart';
import 'package:flutterwave/models/requests/mobile_money/mobile_money_request.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/utils/flutterwave_constants.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';
import 'package:flutterwave/utils/flutterwave_utils.dart';
import 'package:flutterwave/utils/flutterwave_utils_impl.dart';
import 'package:flutterwave/widgets/card_payment/authorization_webview.dart';
import 'package:flutterwave/widgets/flutterwave_view_utils.dart';
import 'package:http/http.dart' as http;

class PayWithMobileMoney extends StatefulWidget {
  final MobileMoneyPaymentManager _paymentManager;

  PayWithMobileMoney(this._paymentManager);

  @override
  _PayWithMobileMoneyState createState() => _PayWithMobileMoneyState();
}

class _PayWithMobileMoneyState extends State<PayWithMobileMoney> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _networkController = TextEditingController();
  final TextEditingController _francophoneCountryCotroller =
      TextEditingController();
  final TextEditingController _voucherController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  BuildContext? loadingDialogContext;
  String? selectedNetwork;
  FrancoPhoneCountry? selectedFrancophoneCountry;
  String updatedNumber = "";

  @override
  Widget build(BuildContext context) {
    final String initialPhoneNumber = updatedNumber.isEmpty
        ? this.widget._paymentManager.phoneNumber
        : updatedNumber;
    this._phoneNumberController.text = initialPhoneNumber;

    final String currency = this.widget._paymentManager.currency;
    return MaterialApp(
      debugShowCheckedModeBanner: widget._paymentManager.isDebugMode,
      home: Scaffold(
        key: this._scaffoldKey,
        appBar: FlutterwaveViewUtils.appBar(context, _getPageTitle(currency)),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 35, 20, 0),
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
                    onChanged: (text) => {updatedNumber = text},
                    validator: (value) => value != null && value.isEmpty
                        ? "Phone number is required"
                        : null,
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    width: double.infinity,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Voucher",
                        hintText: "voucher",
                      ),
                      controller: this._voucherController,
                    ),
                  ),
                  Visibility(
                    visible:
                        currency.toUpperCase() == FlutterwaveCurrency.XAF ||
                            currency.toUpperCase() == FlutterwaveCurrency.XOF,
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      width: double.infinity,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Country",
                          hintText: "Country",
                        ),
                        controller: this._francophoneCountryCotroller,
                        readOnly: true,
                        onTap: this._showFrancophoneBottomSheet,
                        validator: (value) => value != null && value.isEmpty
                            ? "country is required"
                            : null,
                      ),
                    ),
                  ),
                  Visibility(
                    visible:
                        FlutterwaveCurrency.GHS == currency.toUpperCase() ||
                            FlutterwaveCurrency.ZMW == currency.toUpperCase(),
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      width: double.infinity,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: "Network",
                          hintText: "Network",
                        ),
                        controller: this._networkController,
                        readOnly: true,
                        onTap: this._showNetworksBottomSheet,
                        validator: (value) => value != null && value.isEmpty
                            ? "Network is required"
                            : null,
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: EdgeInsets.fromLTRB(0, 40, 0, 20),
                    child: RaisedButton(
                      onPressed: this._onPayPressed,
                      color: Colors.orange,
                      child: Text(
                        "Pay with ${this._getPageTitle(currency)}",
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

  @override
  void dispose() {
    super.dispose();
    this._phoneNumberController.dispose();
  }

  void _onPayPressed() {
    if (this._formKey.currentState!.validate()) {
      final MobileMoneyPaymentManager pm = this.widget._paymentManager;
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

  void _showBottomSheet(final Widget widget) {
    showModalBottomSheet(context: this.context, builder: (context) => widget);
  }

  void _showFrancophoneBottomSheet() {
    this._showBottomSheet(this._getFrancoPhoneCountries());
  }

  void _showNetworksBottomSheet() {
    this._showBottomSheet(this._getNetworksThatAllowMobileMoney());
  }

  Widget _getNetworksThatAllowMobileMoney() {
    final networks =
        FlutterwaveCurrency.getAllowedMobileMoneyNetworksByCurrency(
            this.widget._paymentManager.currency);
    return Container(
      height: 220,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: Colors.white,
      child: ListView(
        children: networks
            .map((network) => ListTile(
                  onTap: () => {this._handleNetworkTap(network)},
                  title: Column(
                    children: [
                      Text(
                        network,
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

  Widget _getFrancoPhoneCountries() {
    FlutterwaveUtils flutterwaveUtils = FlutterwaveUtilsImpl();
    final francoPhoneCountries = flutterwaveUtils
        .getFrancoPhoneCountries(this.widget._paymentManager.currency);
    return Container(
      height: 220,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: Colors.white,
      child: ListView(
        children: francoPhoneCountries
            .map((country) => ListTile(
                  onTap: () =>
                      {this._handleFrancophoneCountrySelected(country)},
                  title: Column(
                    children: [
                      Text(
                        country.name,
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

  void _handleNetworkTap(final String selectedNetwork) {
    this._removeFocusFromView();
    this.setState(() {
      this.selectedNetwork = selectedNetwork;
      this._networkController.text = selectedNetwork;
    });
    Navigator.pop(this.context);
  }

  _handleFrancophoneCountrySelected(final FrancoPhoneCountry country) {
    this._removeFocusFromView();
    this.setState(() {
      this.selectedFrancophoneCountry = country;
      this._francophoneCountryCotroller.text = country.name;
    });
    Navigator.pop(this.context);
  }

  void _removeFocusFromView() {
    FocusScope.of(this.context).requestFocus(FocusNode());
  }

  String _getPageTitle(final String currency) {
    switch (currency.toUpperCase()) {
      case FlutterwaveCurrency.GHS:
        return "Ghana Mobile Money";
      case FlutterwaveCurrency.RWF:
        return "Rwanda Mobile Money";
      case FlutterwaveCurrency.ZMW:
        return "Zambia Mobile Money";
      case FlutterwaveCurrency.UGX:
        return "Uganda Mobile Money";
      case FlutterwaveCurrency.XAF:
        return "Francophone Mobile Money";
      case FlutterwaveCurrency.XOF:
        return "Francophone Mobile Money";
    }
    return "";
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

    final MobileMoneyPaymentManager mobileMoneyPaymentManager =
        this.widget._paymentManager;

    if (this.updatedNumber.isNotEmpty) {
      this.widget._paymentManager.phoneNumber = this.updatedNumber.trim();
    }
    final MobileMoneyRequest request = MobileMoneyRequest(
      amount: mobileMoneyPaymentManager.amount,
      currency: mobileMoneyPaymentManager.currency,
      network: this.selectedNetwork == null ? "" : this.selectedNetwork!,
      txRef: mobileMoneyPaymentManager.txRef,
      fullName: mobileMoneyPaymentManager.fullName,
      email: mobileMoneyPaymentManager.email,
      phoneNumber: this.widget._paymentManager.phoneNumber.trim(),
      voucher: this._voucherController.text,
      redirectUrl: mobileMoneyPaymentManager.redirectUrl,
      country: this.selectedFrancophoneCountry == null
          ? ""
          : this.selectedFrancophoneCountry!.countryCode,
    );

    final http.Client client = http.Client();
    try {
      final response =
          await mobileMoneyPaymentManager.payWithMobileMoney(request, client);
      this._closeDialog();

      if (FlutterwaveConstants.SUCCESS == response.status &&
          FlutterwaveConstants.CHARGE_INITIATED == response.message) {
        if (response.meta!.authorization!.mode == Authorization.REDIRECT &&
            response.meta!.authorization!.redirect != null) {
          this._openOtpScreen(response.meta!.authorization!.redirect!);
          return;
        }
        if (response.meta!.authorization!.mode == Authorization.CALLBACK) {
          this._verifyPayment(response.data!.flwRef!);
          return;
        }
        this._showSnackBar(response.message!);
      } else {
        this._showSnackBar(response.message!);
      }
    } catch (error) {
      this._closeDialog();
      this._showSnackBar(error.toString());
    }
  }

  Future<dynamic> _openOtpScreen(String url) async {
    final result = await Navigator.push(
      this.context,
      MaterialPageRoute(
          builder: (context) => AuthorizationWebview(
              Uri.encodeFull(url), this.widget._paymentManager.redirectUrl!)),
    );
    if (result != null) {
      if (result.runtimeType == " ".runtimeType) {
        this._verifyPayment(result);
      } else {
        this._showSnackBar(result["message"]);
      }
    } else {
      this._showSnackBar("Transaction not completed.");
    }
  }

  void _verifyPayment(final String flwRef) async {
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
        return this._onComplete(response!);
      }
      final client = http.Client();
      try {
        response = await FlutterwaveAPIUtils.verifyPayment(
            flwRef,
            client,
            this.widget._paymentManager.publicKey,
            this.widget._paymentManager.isDebugMode);
        if ((response!.data!.status == FlutterwaveConstants.SUCCESSFUL ||
                response!.data!.status == FlutterwaveConstants.SUCCESS) &&
            response!.data!.amount == this.widget._paymentManager.amount &&
            response!.data!.flwRef == flwRef) {
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
