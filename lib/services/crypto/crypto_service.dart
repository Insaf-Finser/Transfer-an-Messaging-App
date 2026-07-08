import 'package:basic_utils/basic_utils.dart';
import 'package:transfer/core/firestore/user_repository.dart';
import 'package:transfer/services/crypto/aes_service.dart';
import 'package:transfer/services/crypto/key_service.dart';
import 'package:transfer/services/crypto/rsa_service.dart';

class EncryptedPayload {
  final String ciphertext;
  final String iv;
  final String encryptedSessionKey;
  final String senderEncryptedSessionKey;

  const EncryptedPayload({
    required this.ciphertext,
    required this.iv,
    required this.encryptedSessionKey,
    required this.senderEncryptedSessionKey,
  });

  Map<String, dynamic> toFirestore() => {
        'ciphertext': ciphertext,
        'iv': iv,
        'encryptedSessionKey': encryptedSessionKey,
        'senderEncryptedSessionKey': senderEncryptedSessionKey,
      };
}

class CryptoService {
  CryptoService({
    KeyService? keyService,
    RsaService? rsaService,
    AesService? aesService,
    UserRepository? userRepository,
  })  : _keyService = keyService ?? KeyService(),
        _rsaService = rsaService ?? RsaService(),
        _aesService = aesService ?? AesService(),
        _userRepository = userRepository ?? UserRepository();

  final KeyService _keyService;
  final RsaService _rsaService;
  final AesService _aesService;
  final UserRepository _userRepository;

  Future<String?> setupUserKeys(String uid) async {
    final existing = await _keyService.getPrivateKey(uid);
    if (existing != null) {
      final profile = await _userRepository.getProfile(uid);
      return profile?.publicKey;
    }

    final pair = _rsaService.generateKeyPair();
    final publicKey =
        _rsaService.encodePublicKey(pair.publicKey as RSAPublicKey);
    final privateKey =
        _rsaService.encodePrivateKey(pair.privateKey as RSAPrivateKey);

    await _keyService.savePrivateKey(uid, privateKey);
    return publicKey;
  }

  Future<EncryptedPayload> encryptForRecipient({
    required String senderUid,
    required String recipientUid,
    required String plaintext,
  }) async {
    final recipientKey = await _userRepository.getPublicKey(recipientUid);
    final senderKey = await _userRepository.getPublicKey(senderUid);
    if (recipientKey == null || senderKey == null) {
      throw StateError('Missing encryption keys for participants');
    }

    final aesResult = await _aesService.encrypt(plaintext);
    final sessionKeyBytes = _aesService.decodeKey(aesResult['aesKey']!);
    final encryptedSessionKey = _rsaService.encryptWithPublicKey(
      recipientKey,
      sessionKeyBytes,
    );
    final senderEncryptedSessionKey = _rsaService.encryptWithPublicKey(
      senderKey,
      sessionKeyBytes,
    );

    return EncryptedPayload(
      ciphertext: _aesService.combineCiphertextAndMac(
        aesResult['ciphertext']!,
        aesResult['mac']!,
      ),
      iv: aesResult['nonce']!,
      encryptedSessionKey: encryptedSessionKey,
      senderEncryptedSessionKey: senderEncryptedSessionKey,
    );
  }

  Future<String> decryptMessage({
    required String uid,
    required String senderId,
    required String ciphertext,
    required String iv,
    required String encryptedSessionKey,
    String? senderEncryptedSessionKey,
  }) async {
    final privateKeyPem = await _keyService.getPrivateKey(uid);
    if (privateKeyPem == null) {
      throw StateError('No private key found for user');
    }

    final keyToUse = uid == senderId && senderEncryptedSessionKey != null
        ? senderEncryptedSessionKey
        : encryptedSessionKey;

    final sessionKeyBytes =
        _rsaService.decryptWithPrivateKey(privateKeyPem, keyToUse);
    final parts = _aesService.splitCiphertextAndMac(ciphertext);

    return _aesService.decrypt(
      ciphertext: parts.ciphertext,
      nonce: iv,
      mac: parts.mac,
      aesKey: _aesService.encodeKey(sessionKeyBytes),
    );
  }
}
