import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transfer/core/firestore/user_repository.dart';
import 'package:transfer/presentaion/menu/menu.dart';
import 'package:transfer/services/crypto/crypto_service.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final UserRepository _userRepository = UserRepository();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> saveInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final name = nameController.text.trim();
    final username = usernameController.text.trim();
    if (name.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final usernameTaken = await _userRepository.isUsernameTaken(
        username,
        excludeUid: user.uid,
      );
      if (usernameTaken) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is already taken')),
        );
        return;
      }

      final publicKey = await CryptoService().setupUserKeys(user.uid);
      await _userRepository.saveProfile(
        uid: user.uid,
        name: name,
        username: username,
        email: user.email,
        address: addressController.text.trim(),
        publicKey: publicKey,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MenuPage()),
      );
    } catch (e) {
      if (!mounted) return;
      final message = e is UsernameTakenException
          ? 'Username is already taken'
          : e.toString().contains('permission-denied')
              ? 'Firestore permission error. Deploy rules: firebase deploy --only firestore'
              : 'Error: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us about you',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              // Profile Picture Upload
              /*Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: profileImageFile != null
                          ? FileImage(profileImageFile!)
                          : (profileImageUrl != null
                              ? NetworkImage(profileImageUrl!)
                              : null) as ImageProvider<Object>?,
                      child: profileImageFile == null && profileImageUrl == null
                          ? const Icon(Icons.person, size: 48, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: pickProfileImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
               */
              const SizedBox(height: 24),

              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16,),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                minLines: 3,
                maxLines: 5,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : saveInfo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}