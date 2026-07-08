import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transfer/core/firestore/user_repository.dart';
import 'package:transfer/models/user_profile.dart';
import 'package:transfer/presentaion/GetStarted/getstarted.dart';
import 'package:transfer/services/auth/auth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userRepository = UserRepository();
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    final profile = await _userRepository.getProfile(uid);
    if (mounted) {
      setState(() {
        _profile = profile;
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GetStartedPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: const Color(0xFF89E5F5),
              child: Text(
                (_profile?.name.isNotEmpty == true ? _profile!.name[0] : '?')
                    .toUpperCase(),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _profile?.name ?? 'Unknown',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '@${_profile?.username ?? 'username'}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            if (_profile?.email != null) ...[
              const SizedBox(height: 8),
              Text(_profile!.email!),
            ],
            if (_profile?.address != null && _profile!.address!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _profile!.address!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                child: const Text('Log Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
