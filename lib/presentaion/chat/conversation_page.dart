import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transfer/core/firestore/chat_repository.dart';
import 'package:transfer/models/message.dart';
import 'package:transfer/services/crypto/crypto_service.dart';

class ConversationPage extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUserName;

  const ConversationPage({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final _chatRepository = ChatRepository();
  final _cryptoService = CryptoService();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String? _uid;
  bool _sending = false;
  final Map<String, String> _decryptedCache = {};

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<String> _decrypt(ChatMessage message) async {
    if (_decryptedCache.containsKey(message.id)) {
      return _decryptedCache[message.id]!;
    }
    if (_uid == null) return '[Unable to decrypt]';
    try {
      final text = await _cryptoService.decryptMessage(
        uid: _uid!,
        senderId: message.senderId,
        ciphertext: message.ciphertext,
        iv: message.iv,
        encryptedSessionKey: message.encryptedSessionKey,
        senderEncryptedSessionKey: message.senderEncryptedSessionKey,
      );
      _decryptedCache[message.id] = text;
      return text;
    } catch (_) {
      return '[Unable to decrypt]';
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _uid == null || _sending) return;

    setState(() => _sending = true);
    try {
      final encrypted = await _cryptoService.encryptForRecipient(
        senderUid: _uid!,
        recipientUid: widget.otherUserId,
        plaintext: text,
      );

      await _chatRepository.sendMessage(
        chatId: widget.chatId,
        senderId: _uid!,
        recipientId: widget.otherUserId,
        encryptedPayload: encrypted.toFirestore(),
      );

      _messageController.clear();
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _chatRepository.watchMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients && messages.isNotEmpty) {
                    _scrollController.jumpTo(
                      _scrollController.position.maxScrollExtent,
                    );
                  }
                });

                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Send a message to start the conversation',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _uid;
                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF89E5F5)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: FutureBuilder<String>(
                          future: _decrypt(message),
                          builder: (context, snap) {
                            return Text(snap.data ?? '...');
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _sendMessage,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
