import 'package:flutter_test/flutter_test.dart';
import 'package:flutterwave/models/requests/bank_transfer/bank_transfer_request.dart';
import 'package:flutterwave/models/requests/charge_card/charge_card_request.dart';
import 'package:flutterwave/models/requests/charge_card/validate_charge_request.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';
import 'package:flutterwave/utils/flutterwave_urls.dart';

main() {
  group("Bank Transfer Request", () {
    final bankTransferRequest = BankTransferRequest(
        amount: "100",
        currency: FlutterwaveCurrency.NGN,
        duration: "3",
        email: "email.com",
        frequency: "3",
        isPermanent: "false",
        narration: "some narration",
        txRef: "some_ref",
        phoneNumber: "12345");

    test("objects should initialize correctly", () {
      expect("100", bankTransferRequest.amount);
      expect("NGN", bankTransferRequest.currency);
      expect("3", bankTransferRequest.frequency);
    });

    test("toJson() should work correctly", () {
      final json = bankTransferRequest.toJson();

      // ignore: unnecessary_null_comparison
      expect(true, json != null);
      expect("some narration", json["narration"]);
      expect("12345", json["phone_number"]);
      expect("email.com", json["email"]);
    });

    test("should initiate objects properly fromJson()", () {
      final json = bankTransferRequest.toJson();
      final bt = BankTransferRequest.fromJson(json);

      expect(true, bt.runtimeType == BankTransferRequest().runtimeType);
      expect(bt.narration, json["narration"]);
      expect(bt.phoneNumber, json["phone_number"]);
      expect(bt.email, json["email"]);
    });
  });

  group("Charge Card Request", () {
    final chargeCardRequest = ChargeCardRequest(
        amount: "100",
        currency: FlutterwaveCurrency.GHS,
        cardNumber: "1234567890",
        email: "email.com",
        expiryMonth: "12",
        cvv: "419",
        expiryYear: "2090",
        fullName: "FredDominant Tha Boss",
        txRef: "some_ref");

    test("objects should initialize correctly", () {
      expect("100", chargeCardRequest.amount);
      expect("GHS", chargeCardRequest.currency);
      expect("12", chargeCardRequest.expiryMonth);
      expect(true, chargeCardRequest.authorization == null);
      expect(
          FlutterwaveURLS.DEFAULT_REDIRECT_URL, chargeCardRequest.redirectUrl);
    });

    test("toJson() should work correctly", () {
      final json = chargeCardRequest.toJson();

      // ignore: unnecessary_null_comparison
      expect(true, json != null);
      expect("419", json["cvv"]);
      expect("100", json["amount"]);
      expect("email.com", json["email"]);
      expect(true, json["authorization"] != null);
    });
  });

  group("Validate Card Request", () {
    final validateChargeRequest = ValidateChargeRequest("123", "ref");

    test("objects should initialize correctly", () {
      expect("123", validateChargeRequest.otp);
      expect("GHS", validateChargeRequest.flwRef);
      expect(false, validateChargeRequest.isBankAccount);
    });

    test("toJson() should work correctly", () {
      final json = validateChargeRequest.toJson();

      // ignore: unnecessary_null_comparison
      expect(true, json != null);
      expect("419", json["cvv"]);
      expect("100", json["amount"]);
      expect("email.com", json["email"]);
      expect(true, json["authorization"] != null);
    });

    test("fromJson() should work correctly", () {
      final json = validateChargeRequest.toJson();
      final vcr = ValidateChargeRequest.fromJson(json);
      // ignore: unnecessary_null_comparison
      expect(true, json != null);
      expect(vcr.otp, json["otp"]);
      expect(vcr.flwRef, json["flw_ref"]);
    });
  });
}
