import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';

class RsaService {
  AsymmetricKeyPair<PublicKey, PrivateKey> generateKeyPair() {
    return CryptoUtils.generateRSAKeyPair(keySize: 2048);
  }

  String encodePublicKey(RSAPublicKey key) {
    return CryptoUtils.encodeRSAPublicKeyToPemPkcs1(key);
  }

  String encodePrivateKey(RSAPrivateKey key) {
    return CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(key);
  }

  RSAPublicKey decodePublicKey(String pem) {
    return CryptoUtils.rsaPublicKeyFromPemPkcs1(pem);
  }

  RSAPrivateKey decodePrivateKey(String pem) {
    return CryptoUtils.rsaPrivateKeyFromPemPkcs1(pem);
  }

  String encryptWithPublicKey(String publicKeyPem, Uint8List data) {
    final publicKey = decodePublicKey(publicKeyPem);
    final cipher = PKCS1Encoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
    return base64Encode(cipher.process(data));
  }

  Uint8List decryptWithPrivateKey(String privateKeyPem, String encryptedBase64) {
    final privateKey = decodePrivateKey(privateKeyPem);
    final cipher = PKCS1Encoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));
    return cipher.process(base64Decode(encryptedBase64));
  }
}
