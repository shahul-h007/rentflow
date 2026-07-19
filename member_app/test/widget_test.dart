import 'package:flutter_test/flutter_test.dart';
import 'package:member_app/models/models.dart';

void main() {
  test('parses the dashboard account contract', () {
    final account = UserAccount.fromJson({
      'id': 'account-1',
      'email': 'member@example.com',
      'role': 'MEMBER',
      'memberId': 'member-1',
    });

    expect(account.id, 'account-1');
    expect(account.email, 'member@example.com');
    expect(account.memberId, 'member-1');
  });
}
