import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

/// A class to encapsulate the result of authentication operations.
class AuthResult {
  final bool success;
  final User? user;
  final String? verificationId;
  final String? error;
  final bool isNewUser;

  AuthResult({
    required this.success,
    this.user,
    this.verificationId,
    this.error,
    this.isNewUser = false,
  });
}

/// Service class for handling authentication logic.
class AuthService {
  final FirebaseAuth _auth;

  int? _resendToken; // Optional: track resend token for OTP resend

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Sends an OTP to the given [phoneNumber].
  /// You can optionally provide a [timeout] and a [onStatus] callback for logging.
  Future<AuthResult> sendOTP(
    String phoneNumber, {
    Duration timeout = const Duration(seconds: 60),
    void Function(String message)? onStatus,
  }) async {
    // Check if this is a Firebase test number
    final isTestNumber = phoneNumber.replaceAll(RegExp(r'\D'), '').contains('1555555');
    if (isTestNumber) {
      // You may need to import 'package:flutter/foundation.dart' for debugPrint
      // import 'package:flutter/foundation.dart';
      // If not using Flutter, replace debugPrint with print
      // debugPrint('Using Firebase test number - will auto-verify');
      print('Using Firebase test number - will auto-verify');
    }
    try {
      await _auth.signOut();
      final completer = Completer<AuthResult>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (!completer.isCompleted) {
            try {
              final userCredential = await _auth.signInWithCredential(credential);
              completer.complete(AuthResult(
                success: true,
                user: userCredential.user,
                isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
              ));
              onStatus?.call("Phone verification completed automatically.");
            } catch (e) {
              completer.complete(AuthResult(success: false, error: e.toString()));
              onStatus?.call("Automatic sign-in failed: ${e.toString()}");
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!completer.isCompleted) {
            completer.complete(AuthResult(success: false, error: e.message ?? 'Verification failed'));
            onStatus?.call("Verification failed: ${e.message}");
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            _resendToken = resendToken;
            completer.complete(AuthResult(success: true, verificationId: verificationId));
            onStatus?.call("OTP code sent to $phoneNumber.");
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!completer.isCompleted) {
            completer.complete(AuthResult(success: false, error: 'Timeout while waiting for auto-retrieval'));
            onStatus?.call("Auto-retrieval timeout.");
          }
        },
      );

      return await completer.future;
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Verifies the OTP using the [verificationId] and [smsCode].
  Future<AuthResult> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      if (smsCode.length != 6 || !RegExp(r'^\d{6}$').hasMatch(smsCode)) {
        return AuthResult(success: false, error: 'Invalid OTP format');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      return AuthResult(
        success: true,
        user: userCredential.user,
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: e.message ?? 'OTP verification failed');
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  /// Signs out the currently authenticated user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Returns the currently authenticated user, if any.
  User? get currentUser => _auth.currentUser;
}
