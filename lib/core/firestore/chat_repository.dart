import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transfer/core/firestore/firestore_paths.dart';
import 'package:transfer/core/firestore/user_repository.dart';
import 'package:transfer/models/chat.dart';
import 'package:transfer/models/message.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  ChatRepository({
    FirebaseFirestore? firestore,
    UserRepository? userRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _userRepository = userRepository ?? UserRepository();

  final FirebaseFirestore _firestore;
  final UserRepository _userRepository;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection(FirestorePaths.chats);

  Stream<List<ChatSummary>> watchChats(String uid) {
    return _chats
        .where(FirestorePaths.chatParticipants, arrayContains: uid)
        .orderBy(FirestorePaths.chatUpdatedAt, descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final chats = <ChatSummary>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final participants =
            List<String>.from(data[FirestorePaths.chatParticipants] as List? ?? []);
        final otherUid = participants.firstWhere((p) => p != uid, orElse: () => '');
        String? otherName;
        String? otherUsername;
        if (otherUid.isNotEmpty) {
          final profile = await _userRepository.getProfile(otherUid);
          otherName = profile?.name;
          otherUsername = profile?.username;
        }
        chats.add(ChatSummary.fromFirestore(
          doc.id,
          data,
          currentUid: uid,
          otherUserName: otherName,
          otherUsername: otherUsername,
        ));
      }
      return chats;
    });
  }

  Future<String> getOrCreateDirectChat(String uid, String otherUid) async {
    final chatId = FirestorePaths.directChatId(uid, otherUid);
    final ref = _chats.doc(chatId);

    // Use merge set instead of get-then-create: reading a non-existent
    // chat doc is denied by rules that require resource.data.participants.
    await ref.set({
      FirestorePaths.chatParticipants: [uid, otherUid],
      FirestorePaths.chatUpdatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return chatId;
  }

  Stream<List<ChatMessage>> watchMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection(FirestorePaths.messages)
        .orderBy(FirestorePaths.messageTimestamp, descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc.id, doc.data()))
            .toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String recipientId,
    required Map<String, dynamic> encryptedPayload,
  }) async {
    final messageId = _uuid.v4();
    final messageRef = _chats.doc(chatId).collection(FirestorePaths.messages).doc(messageId);

    await messageRef.set({
      FirestorePaths.messageSenderId: senderId,
      FirestorePaths.messageCiphertext: encryptedPayload['ciphertext'],
      FirestorePaths.messageIv: encryptedPayload['iv'],
      FirestorePaths.messageEncryptedSessionKey:
          encryptedPayload['encryptedSessionKey'],
      if (encryptedPayload['senderEncryptedSessionKey'] != null)
        FirestorePaths.messageSenderEncryptedSessionKey:
            encryptedPayload['senderEncryptedSessionKey'],
      FirestorePaths.messageTimestamp: FieldValue.serverTimestamp(),
      FirestorePaths.messageType: FirestorePaths.messageTypeText,
    });

    await _chats.doc(chatId).update({
      FirestorePaths.chatLastMessage: {
        FirestorePaths.messageSenderId: senderId,
        ...encryptedPayload,
        FirestorePaths.messageType: FirestorePaths.messageTypeText,
        FirestorePaths.messageTimestamp: FieldValue.serverTimestamp(),
      },
      FirestorePaths.chatUpdatedAt: FieldValue.serverTimestamp(),
    });
  }
}
