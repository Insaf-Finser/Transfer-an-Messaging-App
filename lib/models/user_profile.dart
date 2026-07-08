class UserProfile {
  final String uid;
  final String name;
  final String username;
  final String? email;
  final String? address;
  final String? publicKey;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.username,
    this.email,
    this.address,
    this.publicKey,
  });

  factory UserProfile.fromFirestore(String uid, Map<String, dynamic> data) {
    return UserProfile(
      uid: uid,
      name: data['name'] as String? ?? '',
      username: data['username'] as String? ?? '',
      email: data['email'] as String?,
      address: data['address'] as String?,
      publicKey: data['publicKey'] as String?,
    );
  }
}
