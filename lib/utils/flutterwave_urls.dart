import 'package:flutterwave/utils/flutterwave_currency.dart';

class FlutterwaveURLS {
  static const String _DEBUG_BASE_URL =
      "https://ravesandboxapi.flutterwave.com/v3/sdkcheckout/";
  static const String _PROD_BASE_URL = "https://api.ravepay.co/v3/sdkcheckout/";
  static const String CHARGE_CARD_URL = "charges?type=card";
  static const String VOUCHER_PAYMENT = "charges?type=voucher_payment";
  static const String BANK_TRANSFER = "charges?type=bank_transfer";
  static const String PAY_WITH_ACCOUNT = "charges?type=debit_ng_account";
  static const String GET_BANKS_URL =
      "https://api.ravepay.co/flwv3-pug/getpaidx/api/flwpbf-banks.js?json=1";
  static const String PAY_WITH_MPESA = "charges?type=mpesa";

  static const String PAY_WITH_USSD = "charges?type=ussd";
  static const String RWANDA_MOBILE_MONEY = "charges?type=mobile_money_rwanda";
  static const String UGANDA_MOBILE_MONEY = "charges?type=mobile_money_uganda";
  static const String ZAMBIA_MOBILE_MONEY = "charges?type=mobile_money_zambia";
  static const String GHANA_MOBILE_MONEY = "charges?type=mobile_money_ghana";
  static const String FRANCOPHONE_MOBILE_MONEY =
      "charges?type=mobile_money_franco";
  static const String VALIDATE_CHARGE = "validate-charge";
  static const String VERIFY_TRANSACTION = "mpesa-verify";
  static const String DEFAULT_REDIRECT_URL = "https://flutterwave.com/ng/";

  /// Returns base url depending on debug mode
  static String getBaseUrl(final bool isDebugMode) {
    return isDebugMode ? _DEBUG_BASE_URL : _PROD_BASE_URL;
  }

  /// Retturns Mobile Money Urls depending on currency
  static String getMobileMoneyUrl(final String currency) {
    switch (currency) {
      case FlutterwaveCurrency.UGX:
        return UGANDA_MOBILE_MONEY;
      case FlutterwaveCurrency.RWF:
        return RWANDA_MOBILE_MONEY;
      case FlutterwaveCurrency.ZMW:
        return ZAMBIA_MOBILE_MONEY;
      case FlutterwaveCurrency.GHS:
        return GHANA_MOBILE_MONEY;
      case FlutterwaveCurrency.XAF:
        return FRANCOPHONE_MOBILE_MONEY;
      case FlutterwaveCurrency.XOF:
        return FRANCOPHONE_MOBILE_MONEY;
    }
    return "";
  }
}
