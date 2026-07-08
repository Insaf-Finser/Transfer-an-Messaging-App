import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

class AesService {
  final algorithm = AesGcm.with256bits();

  Future<Map<String, String>> encrypt(String plaintext) async {
    final secretKey = await algorithm.newSecretKey();
    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );
    final keyBytes = await secretKey.extractBytes();

    return {
      'ciphertext': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'aesKey': base64Encode(keyBytes),
    };
  }

  Future<String> decrypt({
    required String ciphertext,
    required String nonce,
    required String mac,
    required String aesKey,
  }) async {
    final secretBox = SecretBox(
      base64Decode(ciphertext),
      nonce: base64Decode(nonce),
      mac: Mac(base64Decode(mac)),
    );

    final clearText = await algorithm.decrypt(
      secretBox,
      secretKey: SecretKey(base64Decode(aesKey)),
    );

    return utf8.decode(clearText);
  }

  String combineCiphertextAndMac(String ciphertext, String mac) {
    return '$ciphertext.$mac';
  }

  ({String ciphertext, String mac}) splitCiphertextAndMac(String combined) {
    final parts = combined.split('.');
    if (parts.length != 2) {
      throw FormatException('Invalid ciphertext format');
    }
    return (ciphertext: parts[0], mac: parts[1]);
  }

  Uint8List decodeKey(String base64Key) => base64Decode(base64Key);

  String encodeKey(Uint8List keyBytes) => base64Encode(keyBytes);
}
