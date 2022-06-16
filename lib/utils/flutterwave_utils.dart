import 'package:flutterwave/models/francophone_country.dart';

abstract class FlutterwaveUtils {
  /// Encrypts data using 3DES technology.
  /// Returns a String
  String tripleDESEncrypt(dynamic data, String encryptionKey);

  /// Creates a card request with encrypted details
  /// Returns a map.
  Map<String, String> createCardRequest(String encryptedData);

  /// Returns a list of francophone countries by their currencies
  List<FrancoPhoneCountry> getFrancoPhoneCountries(final String currency);
}
