import 'package:flutter_test/flutter_test.dart';
import 'package:transfer/core/firestore/firestore_paths.dart';

void main() {
  test('directChatId is deterministic regardless of order', () {
    expect(
      FirestorePaths.directChatId('aaa', 'bbb'),
      FirestorePaths.directChatId('bbb', 'aaa'),
    );
    expect(
      FirestorePaths.directChatId('aaa', 'bbb'),
      'chat_aaa_bbb',
    );
  });
}
