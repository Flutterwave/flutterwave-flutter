import 'dart:convert';

// A pure dart implementation
import 'package:dart_des/dart_des.dart';
import 'package:flutterwave/core/flutterwave_error.dart';
import 'package:flutterwave/models/francophone_country.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';

class FlutterwaveUtils {
  // Encryption keys

  /// Encrypts data using 3DES technology.
  /// Returns a String
  static Future<String> tripleDESEncrypt(
      dynamic data, String encryptionKey) async {
    List<int> encryptedNew;
    String newEncryption;

    /// Initialization Vector used as part of the CBC 3DES encryption
    /// TODO: Server-side decryption must account for the CBC encryption using an initialization vector stated below
    List<int> iv = [1, 2, 3, 4, 5, 6, 7, 8];
    try {
      DES3 des3CBC =
          DES3(key: encryptionKey.codeUnits, mode: DESMode.CBC, iv: iv);
      encryptedNew = des3CBC.encrypt(data.codeUnits);
      newEncryption = base64.encode(encryptedNew);
      return newEncryption;
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
