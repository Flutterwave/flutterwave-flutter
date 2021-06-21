import 'package:flutter_3des/flutter_3des.dart';
import 'package:flutterwave/core/flutterwave_error.dart';
import 'package:flutterwave/models/francophone_country.dart';
import 'package:flutterwave/utils/flutterwave_currency.dart';
import 'package:encrypt/encrypt.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:tripledes/tripledes.dart';

class FlutterwaveUtils {
  // Encryption keys

  /// Encrypts data using 3DES technology.
  /// Returns a String
  static Future<String> tripleDESEncrypt(
      dynamic data, String encryptionKey) async {
    String _key = new String.fromCharCodes(Key.fromUtf8(encryptionKey).bytes);
    String _iv = IV.fromSecureRandom(64).toString();
    // print(_key.length);
    // print(_iv);
    // print("702040801020305070B0D1101020305070B0D1112110D0B0".length);
    try {
      final blockCipher = BlockCipher(TripleDESEngine(), encryptionKey);
      final String encrypted = blockCipher.encodeB64(data);
      final String _encryptBase64 =
          await Flutter3des.encryptToBase64(data, _key + _key, iv: _iv);
      print("Encrypted: " + encrypted);
      print("Decrypted: " + blockCipher.decodeB64(encrypted));
      print("Encrypted N: " + _encryptBase64);
      print("Decrypted N: " +
          await Flutter3des.decryptFromBase64(_encryptBase64, _key + _key,
              iv: _iv));
      return _encryptBase64;
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
