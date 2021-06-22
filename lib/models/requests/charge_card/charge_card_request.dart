import 'package:flutterwave/flutterwave.dart';
import 'package:flutterwave/models/requests/authorization.dart';
import 'package:flutterwave/utils/flutterwave_urls.dart';

class ChargeCardRequest {
  String cardNumber;
  String cvv;
  String expiryMonth;
  String expiryYear;
  String amount;
  String currency;
  String email;
  String fullName;
  String txRef;
  String? country;
  String? redirectUrl;
  Authorization? authorization;

  /// ChargeCardRequest constructor
  ChargeCardRequest(
      {required this.cardNumber,
      required this.cvv,
      required this.expiryMonth,
      required this.expiryYear,
      required this.currency,
      required this.amount,
      required this.email,
      required this.fullName,
      required this.txRef,
      this.country = FlutterwaveCurrency.NGN,
      this.redirectUrl,
      this.authorization});

  /// Converts ChargeCardRequest instance to a map
  Map<String, dynamic> toJson() {
    return {
      "card_number": this.cardNumber,
      "cvv": this.cvv,
      "expiry_month": this.expiryMonth,
      "expiry_year": this.expiryYear,
      "currency": this.currency,
      "amount": this.amount,
      "email": this.email,
      "fullname": this.fullName,
      "country": this.country,
      "tx_ref": this.txRef,
      "redirect_url": (this.redirectUrl == null || this.redirectUrl!.isEmpty)
          ? FlutterwaveURLS.DEFAULT_REDIRECT_URL
          : this.redirectUrl,
      "authorization": this.authorization == null
          ? Authorization().toJson()
          : this.authorization?.toJson()
    };
  }
}
