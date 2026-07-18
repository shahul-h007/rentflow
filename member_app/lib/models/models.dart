class UserAccount {
  final String id;
  final String email;
  final String role;
  final String? memberId;

  UserAccount({
    required this.id,
    required this.email,
    required this.role,
    this.memberId,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'MEMBER',
      memberId: json['memberId'],
    );
  }
}

class Member {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final bool active;

  Member({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    required this.active,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phone: json['phone'],
      active: json['active'] ?? true,
    );
  }
}

class RentMonth {
  final String id;
  final DateTime startsOn;
  final DateTime endsOn;
  final int rent;
  final String status;
  final List<RentPayment> rentPayments;
  final List<Utility> utilities;
  final List<Expense> expenses;
  final List<Debt> debts;

  RentMonth({
    required this.id,
    required this.startsOn,
    required this.endsOn,
    required this.rent,
    required this.status,
    required this.rentPayments,
    required this.utilities,
    required this.expenses,
    required this.debts,
  });

  factory RentMonth.fromJson(Map<String, dynamic> json) {
    var rentList = json['rentPayments'] as List? ?? [];
    var utilsList = json['utilities'] as List? ?? [];
    var expList = json['expenses'] as List? ?? [];
    var debtsList = json['debts'] as List? ?? [];

    return RentMonth(
      id: json['id'] ?? '',
      startsOn: DateTime.parse(json['startsOn'] ?? DateTime.now().toIso8601String()),
      endsOn: DateTime.parse(json['endsOn'] ?? DateTime.now().toIso8601String()),
      rent: json['rent'] ?? 0,
      status: json['status'] ?? 'OPEN',
      rentPayments: rentList.map((i) => RentPayment.fromJson(i)).toList(),
      utilities: utilsList.map((i) => Utility.fromJson(i)).toList(),
      expenses: expList.map((i) => Expense.fromJson(i)).toList(),
      debts: debtsList.map((i) => Debt.fromJson(i)).toList(),
    );
  }
}

class RentPayment {
  final String id;
  final String monthId;
  final String memberId;
  final int amountDue;
  final int amountPaid;
  final int carryForward;
  final String status;
  final DateTime? paidAt;
  final Member? member;

  RentPayment({
    required this.id,
    required this.monthId,
    required this.memberId,
    required this.amountDue,
    required this.amountPaid,
    required this.carryForward,
    required this.status,
    this.paidAt,
    this.member,
  });

  factory RentPayment.fromJson(Map<String, dynamic> json) {
    return RentPayment(
      id: json['id'] ?? '',
      monthId: json['monthId'] ?? '',
      memberId: json['memberId'] ?? '',
      amountDue: json['amountDue'] ?? 0,
      amountPaid: json['amountPaid'] ?? 0,
      carryForward: json['carryForward'] ?? 0,
      status: json['status'] ?? 'PENDING',
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
    );
  }
}

class Utility {
  final String id;
  final String name;
  final int amount;
  final String status;
  final DateTime? dueDate;
  final String? paidById;
  final Member? paidBy;

  Utility({
    required this.id,
    required this.name,
    required this.amount,
    required this.status,
    this.dueDate,
    this.paidById,
    this.paidBy,
  });

  factory Utility.fromJson(Map<String, dynamic> json) {
    return Utility(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      status: json['status'] ?? 'PENDING',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      paidById: json['paidById'],
      paidBy: json['paidBy'] != null ? Member.fromJson(json['paidBy']) : null,
    );
  }
}

class Expense {
  final String id;
  final String title;
  final int amount;
  final String? notes;
  final DateTime createdAt;
  final String paidById;
  final Member? paidBy;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    this.notes,
    required this.createdAt,
    required this.paidById,
    this.paidBy,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: json['amount'] ?? 0,
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      paidById: json['paidById'] ?? '',
      paidBy: json['paidBy'] != null ? Member.fromJson(json['paidBy']) : null,
    );
  }
}

class Debt {
  final String id;
  final String debtorId;
  final String creditorId;
  final int amount;
  final int settledAmount;
  final String reason;
  final String status;
  final Member? debtor;
  final Member? creditor;

  Debt({
    required this.id,
    required this.debtorId,
    required this.creditorId,
    required this.amount,
    required this.settledAmount,
    required this.reason,
    required this.status,
    this.debtor,
    this.creditor,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] ?? '',
      debtorId: json['debtorId'] ?? '',
      creditorId: json['creditorId'] ?? '',
      amount: json['amount'] ?? 0,
      settledAmount: json['settledAmount'] ?? 0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'OPEN',
      debtor: json['debtor'] != null ? Member.fromJson(json['debtor']) : null,
      creditor: json['creditor'] != null ? Member.fromJson(json['creditor']) : null,
    );
  }
}
