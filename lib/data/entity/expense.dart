class Expense {
  final int id;
  final int date;
  final String category;
  final double amount;
  final String note;

  const Expense({
    this.id = 0,
    this.date = 0,
    this.category = '',
    this.amount = 0.0,
    this.note = '',
  });

  Expense copyWith({
    int? id,
    int? date,
    String? category,
    double? amount,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      date: date ?? this.date,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'category': category,
      'amount': amount,
      'note': note,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: (map['id'] as num?)?.toInt() ?? 0,
      date: (map['date'] as num?)?.toInt() ?? 0,
      category: map['category'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      note: map['note'] as String? ?? '',
    );
  }
}
