import '../debt.dart';

class DebtOptimizer {
  /// Optimizes a list of raw debts to minimize the total number of transactions.
  static List<Debt> optimize(List<Debt> rawDebts) {
    if (rawDebts.isEmpty) return [];

    // 1. Calculate net balances for each member
    final balances = <String, double>{};
    for (final debt in rawDebts) {
      balances[debt.fromMemberId] = (balances[debt.fromMemberId] ?? 0.0) - debt.amount;
      balances[debt.toMemberId] = (balances[debt.toMemberId] ?? 0.0) + debt.amount;
    }

    // 2. Separate into debtors (negative balance) and creditors (positive balance)
    final debtors = <String, double>{};
    final creditors = <String, double>{};

    balances.forEach((memberId, balance) {
      if (balance < -0.01) {
        debtors[memberId] = -balance;
      } else if (balance > 0.01) {
        creditors[memberId] = balance;
      }
    });

    // 3. Greedily match debtors and creditors
    final optimizedDebts = <Debt>[];
    
    final debtorKeys = debtors.keys.toList();
    final creditorKeys = creditors.keys.toList();
    
    int i = 0; // debtor index
    int j = 0; // creditor index

    while (i < debtorKeys.length && j < creditorKeys.length) {
      final debtor = debtorKeys[i];
      final creditor = creditorKeys[j];
      
      final amountOwed = debtors[debtor]!;
      final amountToReceive = creditors[creditor]!;
      
      final settledAmount = amountOwed < amountToReceive ? amountOwed : amountToReceive;

      optimizedDebts.add(Debt(
        fromMemberId: debtor,
        toMemberId: creditor,
        amount: double.parse(settledAmount.toStringAsFixed(2)),
      ));

      debtors[debtor] = amountOwed - settledAmount;
      creditors[creditor] = amountToReceive - settledAmount;

      if (debtors[debtor]! < 0.01) i++;
      if (creditors[creditor]! < 0.01) j++;
    }

    return optimizedDebts;
  }
}
