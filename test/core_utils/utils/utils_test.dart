import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutterwave/models/francophone_country.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';
import 'package:flutterwave/utils/flutterwave_utils.dart';
import 'package:flutterwave/utils/flutterwave_utils_impl_2.dart';

main() {
  FlutterwaveUtils flutterwaveUtils = FlutterwaveUtilsImpl2();
  group("Test for utils", () {
    test("getFrancophoneCountries should return a list of Francophone", () {
      final String currency = FlutterwaveCurrency.XOF;

      final countries = flutterwaveUtils.getFrancoPhoneCountries(currency);
      expect(
          countries.first.runtimeType, FrancoPhoneCountry("", "").runtimeType);
      expect(countries.first.name, "BURKINA FASO");
      expect(countries.first.countryCode, "BF");
      expect(countries.length, 4);

      final String currencyXAF = FlutterwaveCurrency.XAF;
      final country = flutterwaveUtils.getFrancoPhoneCountries(currencyXAF);
      expect(country.first.runtimeType, FrancoPhoneCountry("", "").runtimeType);
      expect(country.first.name, "CAMEROON");
      expect(country.first.countryCode, "CM");
      expect(country.length, 1);
    });

    test("encryptRequest should return a map with key `client`", () {
      final String body = "some random body";
      final Map result = flutterwaveUtils.createCardRequest(body);
      expect(true, result != null);
      expect(true, result["client"] != null);
      expect(result["client"], body);
    });

    test("tripleDESEncrypt should return a string", () {
      final String dataToEncrypt = jsonEncode({"Name": "Fred"});
      final String encryptionKey = "Arsenal";
      final String result =
          flutterwaveUtils.tripleDESEncrypt(dataToEncrypt, encryptionKey);
      expect(true, result != null);
      expect(true, result.length > 0);
    });
  });
}
