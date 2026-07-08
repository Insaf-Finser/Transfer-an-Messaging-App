/// Canonical Firestore collection and field names for Transfer.
///
/// Schema:
/// ```
/// users/{uid}
///   email, createdAt
///   info/profile          → name, username, email, address, publicKey, updatedAt
///   contacts/{contactUid} → addedAt, displayName
///
/// usernames/{username}    → uid, name, username
///
/// chats/{chatId}
///   participants, lastMessage, updatedAt
///   messages/{messageId}
///     senderId, ciphertext, iv, encryptedSessionKey, timestamp, type
/// ```
abstract final class FirestorePaths {
  static const String users = 'users';
  static const String usernames = 'usernames';
  static const String chats = 'chats';
  static const String info = 'info';
  static const String contacts = 'contacts';
  static const String messages = 'messages';

  static const String profileDocId = 'profile';

  /// Profile fields (Phase 2 adds [profilePublicKey]).
  static const String profileName = 'name';
  static const String profileUsername = 'username';
  static const String profileEmail = 'email';
  static const String profileAddress = 'address';
  static const String profilePublicKey = 'publicKey';
  static const String profileUpdatedAt = 'updatedAt';

  /// Username registry fields (`usernames/{username}`).
  static const String usernameUid = 'uid';
  static const String usernameName = 'name';

  /// Root user document fields.
  static const String userEmail = 'email';
  static const String userCreatedAt = 'createdAt';

  /// Chat document fields.
  static const String chatParticipants = 'participants';
  static const String chatLastMessage = 'lastMessage';
  static const String chatUpdatedAt = 'updatedAt';

  /// Encrypted message fields.
  static const String messageSenderId = 'senderId';
  static const String messageCiphertext = 'ciphertext';
  static const String messageIv = 'iv';
  static const String messageEncryptedSessionKey = 'encryptedSessionKey';
  static const String messageSenderEncryptedSessionKey =
      'senderEncryptedSessionKey';
  static const String messageTimestamp = 'timestamp';
  static const String messageType = 'type';
  static const String messageTypeText = 'text';

  /// Deterministic 1:1 chat id: `chat_{smallerUid}_{largerUid}`.
  static String directChatId(String uidA, String uidB) {
    final sorted = [uidA, uidB]..sort();
    return 'chat_${sorted[0]}_${sorted[1]}';
  }
}
