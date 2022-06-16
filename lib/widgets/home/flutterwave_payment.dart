import 'package:flutter/material.dart';
import 'package:flutterwave/core/bank_transfer_manager/bank_transfer_payment_manager.dart';
import 'package:flutterwave/core/card_payment_manager/card_payment_manager.dart';
import 'package:flutterwave/core/flutterwave_payment_manager.dart';
import 'package:flutterwave/core/mobile_money/mobile_money_payment_manager.dart';
import 'package:flutterwave/core/mpesa/mpesa_payment_manager.dart';
import 'package:flutterwave/core/pay_with_account_manager/bank_account_manager.dart';
import 'package:flutterwave/core/ussd_payment_manager/ussd_manager.dart';
import 'package:flutterwave/core/voucher_payment/voucher_payment_manager.dart';
import 'package:flutterwave/models/responses/charge_response.dart';
import 'package:flutterwave/widgets/bank_account_payment/bank_account_payment.dart';
import 'package:flutterwave/widgets/bank_transfer_payment/bank_transfer_payment.dart';
import 'package:flutterwave/widgets/card_payment/card_payment.dart';
import 'package:flutterwave/widgets/mobile_money/pay_with_mobile_money.dart';
import 'package:flutterwave/widgets/mpesa_payment/pay_with_mpesa.dart';
import 'package:flutterwave/widgets/ussd_payment/pay_with_ussd.dart';
import 'package:flutterwave/widgets/voucher_payment/pay_with_voucher.dart';

import 'flutterwave_payment_option.dart';

class FlutterwaveUI extends StatefulWidget {
  final FlutterwavePaymentManager _flutterwavePaymentManager;

  FlutterwaveUI(this._flutterwavePaymentManager);

  @override
  _FlutterwaveUIState createState() => _FlutterwaveUIState();
}

class _FlutterwaveUIState extends State<FlutterwaveUI> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final FlutterwavePaymentManager paymentManager =
        this.widget._flutterwavePaymentManager;

    return MaterialApp(
      debugShowCheckedModeBanner: paymentManager.isDebugMode,
      theme: ThemeData(fontFamily: "FLW"),
      home: Scaffold(
        key: this._scaffoldKey,
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height,
            ),
            child: SafeArea(
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 50, 10, 70),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 10.0,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                "SECURED BY FLUTTERWAVE",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 10.0,
                                    fontFamily: "FLW",
                                    letterSpacing: 1.0),
                              )
                            ],
                          ),
                          SizedBox(
                            width: double.infinity,
                            height: 100,
                          ),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
                            child: Text(
                              "How would you \nlike to pay?",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontFamily: "FLW",
                                fontSize: 30.0,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 5,
                              width: 200,
                              color: Colors.pink,
                              margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white38,
                      width: double.infinity,
                      child: Column(
                        children: [
                          Visibility(
                            visible: paymentManager.acceptAccountPayment,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick:
                                        this._launchPayWithAccountWidget,
                                    buttonText: "Account",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: paymentManager.acceptCardPayment,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick: this._launchCardPaymentWidget,
                                    buttonText: "Card",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: paymentManager.acceptUSSDPayment,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick: this._launchUSSDPaymentWidget,
                                    buttonText: "USSD",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: paymentManager.acceptBankTransferPayment,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick:
                                        this._launchBankTransferPaymentWidget,
                                    buttonText: "Bank Transfer",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: paymentManager.acceptMpesaPayment,
                            child: Column(children: [
                              SizedBox(
                                height: 50.0,
                                child: FlutterwavePaymentOption(
                                  handleClick: this._launchMpesaPaymentWidget,
                                  buttonText: "Mpesa",
                                ),
                              ),
                              SizedBox(
                                height: 0.5,
                              ),
                            ]),
                          ),
                          Visibility(
                            visible: paymentManager.acceptRwandaMoneyPayment,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick:
                                        this._launchMobileMoneyPaymentWidget,
                                    buttonText: "Rwanda Mobile Money",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: paymentManager.acceptGhanaPayment,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick:
                                        this._launchMobileMoneyPaymentWidget,
                                    buttonText: "Ghana Mobile Money",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: paymentManager.acceptUgandaPayment,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick:
                                        this._launchMobileMoneyPaymentWidget,
                                    buttonText: "Uganda Mobile Money",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: paymentManager.acceptZambiaPayment,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick:
                                        this._launchMobileMoneyPaymentWidget,
                                    buttonText: "Zambia Mobile Money",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: false,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick: () => {},
                                    buttonText: "Barter",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: paymentManager.acceptVoucherPayment,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                  child: FlutterwavePaymentOption(
                                    handleClick:
                                        this._launchVoucherPaymentWidget,
                                    buttonText: "Voucher",
                                  ),
                                ),
                                SizedBox(
                                  height: 0.5,
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: paymentManager.acceptFancophoneMobileMoney,
                            child: SizedBox(
                              height: 50.0,
                              child: FlutterwavePaymentOption(
                                handleClick:
                                    this._launchMobileMoneyPaymentWidget,
                                buttonText: "Francophone Mobile Money",
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _launchCardPaymentWidget() async {
    final CardPaymentManager cardPaymentManager =
        this.widget._flutterwavePaymentManager.getCardPaymentManager();

    final dynamic response = await Navigator.push(
      this.context,
      MaterialPageRoute(builder: (context) => CardPayment(cardPaymentManager)),
    );
    _handleBackPress(response);
  }

  void _launchPayWithAccountWidget() async {
    final BankAccountPaymentManager bankAccountPaymentManager =
        this.widget._flutterwavePaymentManager.getBankAccountPaymentManager();
    final response = await Navigator.push(
      this.context,
      MaterialPageRoute(
          builder: (context) => PayWithBankAccount(bankAccountPaymentManager)),
    );
    _handleBackPress(response);
  }

  void _launchUSSDPaymentWidget() async {
    final USSDPaymentManager paymentManager =
        this.widget._flutterwavePaymentManager.getUSSDPaymentManager();
    final response = await Navigator.push(
      this.context,
      MaterialPageRoute(builder: (context) => PayWithUssd(paymentManager)),
    );
    _handleBackPress(response);
  }

  void _launchMobileMoneyPaymentWidget() async {
    final MobileMoneyPaymentManager mobileMoneyPaymentManager =
        this.widget._flutterwavePaymentManager.getMobileMoneyPaymentManager();
    final response = await Navigator.push(
      this.context,
      MaterialPageRoute(
          builder: (context) => PayWithMobileMoney(mobileMoneyPaymentManager)),
    );
    _handleBackPress(response);
  }

  void _launchMpesaPaymentWidget() async {
    final FlutterwavePaymentManager paymentManager =
        this.widget._flutterwavePaymentManager;
    final MpesaPaymentManager mpesaPaymentManager =
        paymentManager.getMpesaPaymentManager();
    final response = await Navigator.push(
      this.context,
      MaterialPageRoute(
          builder: (context) => PayWithMpesa(mpesaPaymentManager)),
    );
    _handleBackPress(response);
  }

  void _launchVoucherPaymentWidget() async {
    final VoucherPaymentManager voucherPaymentManager =
        this.widget._flutterwavePaymentManager.getVoucherPaymentManager();
    final response = await Navigator.push(
      this.context,
      MaterialPageRoute(
          builder: (context) => PayWithVoucher(voucherPaymentManager)),
    );
    _handleBackPress(response);
  }

  void _launchBankTransferPaymentWidget() async {
    final BankTransferPaymentManager bankTransferPaymentManager =
        this.widget._flutterwavePaymentManager.getBankTransferPaymentManager();
    final response = await Navigator.push(
      this.context,
      MaterialPageRoute(
          builder: (context) =>
              PayWithBankTransfer(bankTransferPaymentManager)),
    );
    _handleBackPress(response);
  }

  void showSnackBar(String message) {
    SnackBar snackBar = SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
    this._scaffoldKey.currentState!.showSnackBar(snackBar);
  }

  void _handleBackPress(dynamic result) {
    if (result == null || result is ChargeResponse) {
      final ChargeResponse? chargeResponse = result as ChargeResponse?;
      String message;
      if (chargeResponse != null) {
        message = chargeResponse.message!;
      } else {
        message = "Transaction cancelled";
      }
      this.showSnackBar(message);
      Navigator.pop(this.context, chargeResponse);
    } else {
      // checking if back arrow was pressed so we do nothing.
    }
  }
}
