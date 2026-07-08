import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transfer/core/firestore/chat_repository.dart';
import 'package:transfer/core/firestore/user_repository.dart';
import 'package:transfer/models/user_profile.dart';
import 'package:transfer/presentaion/chat/conversation_page.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({super.key});

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  final _searchController = TextEditingController();
  final _userRepository = UserRepository();
  final _chatRepository = ChatRepository();

  List<UserProfile> _results = [];
  bool _searching = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_uid == null) return;
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _searching = true);
    try {
      final results = await _userRepository.searchByUsername(
        query,
        excludeUid: _uid!,
      );
      setState(() => _results = results);
    } finally {
      setState(() => _searching = false);
    }
  }

  Future<void> _startChat(UserProfile user) async {
    if (_uid == null) return;
    try {
      final chatId = await _chatRepository.getOrCreateDirectChat(_uid!, user.uid);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConversationPage(
            chatId: chatId,
            otherUserId: user.uid,
            otherUserName: user.name,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start chat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Users'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by username',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _searching ? null : _search,
                  icon: _searching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? const Center(
                      child: Text(
                        'Search for users by username',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final user = _results[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF89E5F5),
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(user.name),
                          subtitle: Text('@${user.username}'),
                          trailing: const Icon(Icons.chat_bubble_outline),
                          onTap: () => _startChat(user),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
