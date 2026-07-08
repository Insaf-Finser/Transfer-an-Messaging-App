import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:transfer/services/crypto/aes_service.dart';
import 'package:transfer/services/crypto/rsa_service.dart';

void main() {
  group('AesService', () {
    test('encrypt and decrypt roundtrip', () async {
      const plaintext = 'Hello, Transfer!';
      final aes = AesService();

      final encrypted = await aes.encrypt(plaintext);
      final decrypted = await aes.decrypt(
        ciphertext: encrypted['ciphertext']!,
        nonce: encrypted['nonce']!,
        mac: encrypted['mac']!,
        aesKey: encrypted['aesKey']!,
      );

      expect(decrypted, plaintext);
    });

    test('combine and split ciphertext preserves mac', () {
      final aes = AesService();
      const ciphertext = 'abc';
      const mac = 'def';

      final combined = aes.combineCiphertextAndMac(ciphertext, mac);
      final split = aes.splitCiphertextAndMac(combined);

      expect(split.ciphertext, ciphertext);
      expect(split.mac, mac);
    });
  });

  group('RsaService', () {
    test('encrypt and decrypt session key roundtrip', () {
      final rsa = RsaService();
      final pair = rsa.generateKeyPair();
      final publicKey = rsa.encodePublicKey(pair.publicKey as RSAPublicKey);
      final privateKey = rsa.encodePrivateKey(pair.privateKey as RSAPrivateKey);

      final sessionKey = Uint8List.fromList(List.generate(32, (i) => i));
      final encrypted = rsa.encryptWithPublicKey(publicKey, sessionKey);
      final decrypted = rsa.decryptWithPrivateKey(privateKey, encrypted);

      expect(decrypted, sessionKey);
    });
  });
}
