import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyService {
  static const _storage = FlutterSecureStorage();

  Future<void> savePrivateKey(
    String uid,
    String privateKey,
  ) async {
    await _storage.write(
      key: "rsa_private_$uid",
      value: privateKey,
    );
  }

  Future<String?> getPrivateKey(
    String uid,
  ) async {
    return await _storage.read(
      key: "rsa_private_$uid",
    );
  }

  Future<void> deletePrivateKey(
    String uid,
  ) async {
    await _storage.delete(
      key: "rsa_private_$uid",
    );
  }
}