import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transfer/core/firestore/chat_repository.dart';
import 'package:transfer/models/chat.dart';
import 'package:transfer/presentaion/chat/conversation_page.dart';
import 'package:transfer/services/crypto/crypto_service.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final _chatRepository = ChatRepository();
  final _cryptoService = CryptoService();

  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<String> _previewText(ChatSummary chat) async {
    final last = chat.lastMessage;
    if (last == null || _uid == null) return 'No messages yet';
    try {
      return await _cryptoService.decryptMessage(
        uid: _uid!,
        senderId: last['senderId'] as String? ?? '',
        ciphertext: last['ciphertext'] as String? ?? '',
        iv: last['iv'] as String? ?? '',
        encryptedSessionKey: last['encryptedSessionKey'] as String? ?? '',
        senderEncryptedSessionKey:
            last['senderEncryptedSessionKey'] as String?,
      );
    } catch (_) {
      return 'Encrypted message';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_uid == null) {
      return const Center(child: Text('Please sign in to view chats'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<ChatSummary>>(
        stream: _chatRepository.watchChats(_uid!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];
          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'No conversations yet.\nUse Search to find users.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF89E5F5),
                  child: Text(
                    (chat.otherUserName?.isNotEmpty == true
                            ? chat.otherUserName![0]
                            : '?')
                        .toUpperCase(),
                  ),
                ),
                title: Text(
                  chat.otherUserName ?? chat.otherUsername ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: FutureBuilder<String>(
                  future: _previewText(chat),
                  builder: (context, preview) {
                    return Text(
                      preview.data ?? '...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                trailing: chat.updatedAt != null
                    ? Text(
                        _formatTime(chat.updatedAt!),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    : null,
                onTap: () {
                  if (chat.otherUserId == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConversationPage(
                        chatId: chat.id,
                        otherUserId: chat.otherUserId!,
                        otherUserName: chat.otherUserName ?? 'Chat',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inDays == 0) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}';
  }
}
