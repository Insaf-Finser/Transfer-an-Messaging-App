import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:transfer/core/firestore/firestore_paths.dart';
import 'package:transfer/models/user_profile.dart';

class UsernameTakenException implements Exception {
  const UsernameTakenException();

  @override
  String toString() => 'Username is already taken';
}

/// Firestore access for user root docs and profiles.
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> userRef(String uid) =>
      _firestore.collection(FirestorePaths.users).doc(uid);

  DocumentReference<Map<String, dynamic>> profileRef(String uid) =>
      userRef(uid)
          .collection(FirestorePaths.info)
          .doc(FirestorePaths.profileDocId);

  DocumentReference<Map<String, dynamic>> usernameRef(String username) =>
      _firestore
          .collection(FirestorePaths.usernames)
          .doc(username.trim().toLowerCase());

  Future<void> ensureUserDocument({
    required String uid,
    String? email,
    String? phoneNumber,
  }) async {
    await userRef(uid).set({
      if (email != null) FirestorePaths.userEmail: email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      FirestorePaths.userCreatedAt: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<bool> hasProfile(String uid) async {
    final doc = await profileRef(uid).get();
    return doc.exists;
  }

  Future<UserProfile?> getProfile(String uid) async {
    final doc = await profileRef(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfile.fromFirestore(uid, doc.data()!);
  }

  Future<String?> getPublicKey(String uid) async {
    final profile = await getProfile(uid);
    return profile?.publicKey;
  }

  Future<bool> isUsernameTaken(String username, {String? excludeUid}) async {
    final normalized = username.trim().toLowerCase();
    if (normalized.isEmpty) return false;

    final doc = await usernameRef(normalized).get();
    if (!doc.exists) return false;

    final ownerUid = doc.data()?[FirestorePaths.usernameUid] as String?;
    if (ownerUid == null || ownerUid == excludeUid) return false;
    return true;
  }

  Future<void> saveProfile({
    required String uid,
    required String name,
    required String username,
    String? email,
    String? address,
    String? publicKey,
  }) async {
    final normalized = username.trim().toLowerCase();

    await _firestore.runTransaction((transaction) async {
      final registryRef = usernameRef(normalized);
      final existing = await transaction.get(registryRef);
      if (existing.exists) {
        final ownerUid =
            existing.data()?[FirestorePaths.usernameUid] as String?;
        if (ownerUid != null && ownerUid != uid) {
          throw const UsernameTakenException();
        }
      }

      transaction.set(registryRef, {
        FirestorePaths.usernameUid: uid,
        FirestorePaths.usernameName: name,
        FirestorePaths.profileUsername: normalized,
      });

      transaction.set(profileRef(uid), {
        FirestorePaths.profileName: name,
        FirestorePaths.profileUsername: normalized,
        if (email != null) FirestorePaths.profileEmail: email,
        if (address != null && address.isNotEmpty)
          FirestorePaths.profileAddress: address,
        if (publicKey != null) FirestorePaths.profilePublicKey: publicKey,
        FirestorePaths.profileUpdatedAt: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<List<UserProfile>> searchByUsername(
    String query, {
    required String excludeUid,
    int limit = 20,
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return [];

    final snapshot = await _firestore
        .collection(FirestorePaths.usernames)
        .where(FieldPath.documentId, isGreaterThanOrEqualTo: normalized)
        .where(FieldPath.documentId, isLessThanOrEqualTo: '$normalized\uf8ff')
        .limit(limit)
        .get();

    final results = <UserProfile>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final uid = data[FirestorePaths.usernameUid] as String?;
      if (uid == null || uid == excludeUid) continue;

      final profile = await getProfile(uid);
      if (profile != null) {
        results.add(profile);
        continue;
      }

      results.add(UserProfile(
        uid: uid,
        name: data[FirestorePaths.usernameName] as String? ?? '',
        username: data[FirestorePaths.profileUsername] as String? ?? doc.id,
      ));
    }
    return results;
  }
}
