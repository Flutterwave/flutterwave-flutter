// A pure dart implementation
import 'package:dart_3des/dart_3des.dart';
import 'package:flutterwave/core/flutterwave_error.dart';
import 'package:flutterwave/models/francophone_country.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';

class FlutterwaveUtils {
  /// Encrypts data using 3DES technology.
  /// Returns a String
  static Future<String> tripleDESEncrypt(
      dynamic data, String encryptionKey) async {
    try {
      final blockCipher = BlockCipher(TripleDESEngine(), encryptionKey);
      return blockCipher.encodeB64(data);
    } catch (error) {
      throw (FlutterWaveError("Unable to encrypt request"));
    }
  }

  /// Creates a card request with encrypted details
  /// Returns a map.
  static Map<String, String> createCardRequest(String encryptedData) {
    return {"client": encryptedData};
  }

  /// Returns a list of francophone countries by their currencies
  static List<FrancoPhoneCountry> getFrancoPhoneCountries(
      final String currency) {
    if (currency == FlutterwaveCurrency.XAF)
      return [FrancoPhoneCountry("CAMEROON", "CM")];
    return [
      FrancoPhoneCountry("BURKINA FASO", "BF"),
      FrancoPhoneCountry("COTE D'IVOIRE", "CI"),
      FrancoPhoneCountry("GUINEA", "GN"),
      FrancoPhoneCountry("SENEGAL", "SN"),
    ];
  }
}
