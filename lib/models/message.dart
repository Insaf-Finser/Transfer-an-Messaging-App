import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transfer/core/firestore/firestore_paths.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String ciphertext;
  final String iv;
  final String encryptedSessionKey;
  final String? senderEncryptedSessionKey;
  final DateTime timestamp;
  final String type;
  final String? plaintext;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.ciphertext,
    required this.iv,
    required this.encryptedSessionKey,
    this.senderEncryptedSessionKey,
    required this.timestamp,
    required this.type,
    this.plaintext,
  });

  factory ChatMessage.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      senderId: data[FirestorePaths.messageSenderId] as String? ?? '',
      ciphertext: data[FirestorePaths.messageCiphertext] as String? ?? '',
      iv: data[FirestorePaths.messageIv] as String? ?? '',
      encryptedSessionKey:
          data[FirestorePaths.messageEncryptedSessionKey] as String? ?? '',
      senderEncryptedSessionKey:
          data[FirestorePaths.messageSenderEncryptedSessionKey] as String?,
      timestamp: (data[FirestorePaths.messageTimestamp] as Timestamp?)?.toDate() ??
          DateTime.now(),
      type: data[FirestorePaths.messageType] as String? ??
          FirestorePaths.messageTypeText,
    );
  }

  ChatMessage copyWith({String? plaintext}) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      ciphertext: ciphertext,
      iv: iv,
      encryptedSessionKey: encryptedSessionKey,
      senderEncryptedSessionKey: senderEncryptedSessionKey,
      timestamp: timestamp,
      type: type,
      plaintext: plaintext ?? this.plaintext,
    );
  }
}
