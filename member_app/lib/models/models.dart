export 'activity.dart';

class HouseInfo {
  final String id;
  final String name;
  final int rent;
  final String? upiId;
  final String? ownerName;

  HouseInfo({
    required this.id,
    required this.name,
    required this.rent,
    this.upiId,
    this.ownerName,
  });

  factory HouseInfo.fromJson(Map<String, dynamic> json) {
    return HouseInfo(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rent: json['rent'] ?? 0,
      upiId: json['upiId'],
      ownerName: json['ownerName'],
    );
  }
}

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

class RentPaymentTransaction {
  final String id;
  final int amount;
  final String method;
  final String status;
  final String? reference;
  final String? screenshotUrl;
  final DateTime paidAt;
  final Member? payer;

  RentPaymentTransaction({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    this.reference,
    this.screenshotUrl,
    required this.paidAt,
    this.payer,
  });

  factory RentPaymentTransaction.fromJson(Map<String, dynamic> json) {
    return RentPaymentTransaction(
      id: json['id'] ?? '',
      amount: json['amount'] ?? 0,
      method: json['method'] ?? 'CASH',
      status: json['status'] ?? 'SUBMITTED',
      reference: json['reference'],
      screenshotUrl: json['screenshotUrl'],
      paidAt: DateTime.parse(json['paidAt'] ?? DateTime.now().toIso8601String()),
      payer: json['payer'] != null ? Member.fromJson(json['payer']) : null,
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
  final List<RentPaymentTransaction> transactions;

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
    this.transactions = const [],
  });

  factory RentPayment.fromJson(Map<String, dynamic> json) {
    var txs = <RentPaymentTransaction>[];
    if (json['transactions'] != null) {
      txs = (json['transactions'] as List)
          .map((t) => RentPaymentTransaction.fromJson(t))
          .toList();
    }

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
      transactions: txs,
    );
  }
}

class UtilityPayment {
  final String id;
  final String memberId;
  final int amountDue;
  final int amountPaid;
  final String status;
  final Member? member;

  UtilityPayment({
    required this.id,
    required this.memberId,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
    this.member,
  });

  factory UtilityPayment.fromJson(Map<String, dynamic> json) {
    return UtilityPayment(
      id: json['id'] ?? '',
      memberId: json['memberId'] ?? '',
      amountDue: json['amountDue'] ?? 0,
      amountPaid: json['amountPaid'] ?? 0,
      status: json['status'] ?? 'PENDING',
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
    );
  }
}

class Utility {
  final String id;
  final String name;
  final int amount;
  final String splitType;
  final String status;
  final DateTime? dueDate;
  final String? paidById;
  final Member? paidBy;
  final List<UtilityPayment> payments;

  Utility({
    required this.id,
    required this.name,
    required this.amount,
    required this.splitType,
    required this.status,
    this.dueDate,
    this.paidById,
    this.paidBy,
    this.payments = const [],
  });

  factory Utility.fromJson(Map<String, dynamic> json) {
    var p = <UtilityPayment>[];
    if (json['payments'] != null) {
      p = (json['payments'] as List).map((x) => UtilityPayment.fromJson(x)).toList();
    }

    return Utility(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      splitType: json['splitType'] ?? 'EQUAL',
      status: json['status'] ?? 'PENDING',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      paidById: json['paidById'],
      paidBy: json['paidBy'] != null ? Member.fromJson(json['paidBy']) : null,
      payments: p,
    );
  }
}

class ExpenseSplit {
  final String id;
  final String memberId;
  final int amount;
  final Member? member;

  ExpenseSplit({
    required this.id,
    required this.memberId,
    required this.amount,
    this.member,
  });

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    return ExpenseSplit(
      id: json['id'] ?? '',
      memberId: json['memberId'] ?? '',
      amount: json['amount'] ?? 0,
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
    );
  }
}

class Expense {
  final String id;
  final String title;
  final int amount;
  final String splitType;
  final String? notes;
  final DateTime createdAt;
  final String paidById;
  final Member? paidBy;
  final List<ExpenseSplit> splits;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.splitType,
    this.notes,
    required this.createdAt,
    required this.paidById,
    this.paidBy,
    this.splits = const [],
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    var s = <ExpenseSplit>[];
    if (json['splits'] != null) {
      s = (json['splits'] as List).map((x) => ExpenseSplit.fromJson(x)).toList();
    }

    return Expense(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      amount: json['amount'] ?? 0,
      splitType: json['splitType'] ?? 'EQUAL',
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      paidById: json['paidById'] ?? '',
      paidBy: json['paidBy'] != null ? Member.fromJson(json['paidBy']) : null,
      splits: s,
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
