import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSummary {
  final String id;
  final List<String> participants;
  final Map<String, dynamic>? lastMessage;
  final DateTime? updatedAt;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUsername;

  const ChatSummary({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.updatedAt,
    this.otherUserId,
    this.otherUserName,
    this.otherUsername,
  });

  factory ChatSummary.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    String? currentUid,
    String? otherUserName,
    String? otherUsername,
  }) {
    final participants = List<String>.from(data['participants'] as List? ?? []);
    final otherUserId = currentUid == null
        ? null
        : participants.firstWhere((p) => p != currentUid, orElse: () => '');

    return ChatSummary(
      id: id,
      participants: participants,
      lastMessage: data['lastMessage'] as Map<String, dynamic>?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      otherUserId: otherUserId?.isEmpty == true ? null : otherUserId,
      otherUserName: otherUserName,
      otherUsername: otherUsername,
    );
  }
}
