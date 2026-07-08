import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transfer/core/firestore/user_repository.dart';
import 'package:transfer/presentaion/GetStarted/getstarted.dart';
import 'package:transfer/presentaion/Information/info.dart';
import 'package:transfer/presentaion/menu/menu.dart';

/// Routes the user to the correct screen after authentication.
class PostAuthNavigator {
  static Future<void> navigate(BuildContext context, {String? phoneNumber}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedPage()),
      );
      return;
    }

    final userRepository = UserRepository();
    if (phoneNumber != null) {
      await userRepository.ensureUserDocument(
        uid: user.uid,
        phoneNumber: phoneNumber,
      );
    }

    final hasProfile = await userRepository.hasProfile(user.uid);
    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => hasProfile ? const MenuPage() : const InfoPage(),
      ),
    );
  }
}
