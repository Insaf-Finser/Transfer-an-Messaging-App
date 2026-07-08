# Transfer

A Flutter secure messaging app with Firebase Authentication, Cloud Firestore, and end-to-end encryption.

## Features

- Phone OTP and email/password authentication
- User profile onboarding (name, username, address)
- RSA + AES-GCM end-to-end encrypted 1:1 messaging
- Real-time chat list and conversations
- User search by username
- Secure private key storage via `flutter_secure_storage`

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install)
2. Configure Firebase for your platform (`firebase_options.dart`, `google-services.json`)
3. Install dependencies:

```bash
flutter pub get
```

4. Deploy Firestore rules and indexes:

```bash
firebase deploy --only firestore
```

5. Run the app:

```bash
flutter run
```

## Architecture

```
lib/
├── core/firestore/     # User & chat repositories, Firestore paths
├── services/
│   ├── auth/           # Firebase Auth (phone + email)
│   └── crypto/         # RSA key generation, AES-GCM encrypt/decrypt
├── models/             # UserProfile, ChatSummary, ChatMessage
└── presentaion/        # UI screens (auth, chat, search, profile)
```

## Encryption Flow

1. Each user generates an RSA-2048 key pair on profile setup
2. Public keys are stored in Firestore; private keys stay on-device
3. Messages are encrypted with a per-message AES-256-GCM key
4. The AES key is RSA-encrypted separately for sender and recipient

## Firestore Schema

- `users/{uid}/info/profile` — user profile + public key
- `chats/{chatId}` — 1:1 conversations with encrypted last message preview
- `chats/{chatId}/messages/{messageId}` — encrypted message payloads
