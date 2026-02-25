enum TransactionType {
  topup,
  groomingPayment,
  hotelPayment,
  refund,
  adjustment;

  String get value {
    switch (this) {
      case TransactionType.topup:
        return 'TOPUP';
      case TransactionType.groomingPayment:
        return 'GROOMING_PAYMENT';
      case TransactionType.hotelPayment:
        return 'HOTEL_PAYMENT';
      case TransactionType.refund:
        return 'REFUND';
      case TransactionType.adjustment:
        return 'ADJUSTMENT';
    }
  }

  static TransactionType fromString(String? value) {
    switch (value) {
      case 'GROOMING_PAYMENT':
        return TransactionType.groomingPayment;
      case 'HOTEL_PAYMENT':
        return TransactionType.hotelPayment;
      case 'REFUND':
        return TransactionType.refund;
      case 'ADJUSTMENT':
        return TransactionType.adjustment;
      case 'TOPUP':
      default:
        return TransactionType.topup;
    }
  }
}

// ─── OwnerDeposit ───────────────────────────────────────────────────────────

class OwnerDeposit {
  final String ownerPhone; // Primary key
  final String ownerName;
  final double balance;
  final int lastUpdated;

  const OwnerDeposit({
    required this.ownerPhone,
    required this.ownerName,
    required this.balance,
    required this.lastUpdated,
  });

  OwnerDeposit copyWith({
    String? ownerPhone,
    String? ownerName,
    double? balance,
    int? lastUpdated,
  }) {
    return OwnerDeposit(
      ownerPhone: ownerPhone ?? this.ownerPhone,
      ownerName: ownerName ?? this.ownerName,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerPhone': ownerPhone,
      'ownerName': ownerName,
      'balance': balance,
      'lastUpdated': lastUpdated,
    };
  }

  factory OwnerDeposit.fromMap(Map<String, dynamic> map) {
    return OwnerDeposit(
      ownerPhone: map['ownerPhone'] as String? ?? '',
      ownerName: map['ownerName'] as String? ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: (map['lastUpdated'] as num?)?.toInt() ?? 0,
    );
  }
}

// ─── DepositTransaction ─────────────────────────────────────────────────────

class DepositTransaction {
  final int id;
  final String ownerPhone;
  final double amount; // Positive = Credit (TopUp), Negative = Debit (Usage)
  final TransactionType type;
  final int? referenceId; // ID of Booking or Session
  final String notes;
  final int timestamp;

  const DepositTransaction({
    this.id = 0,
    required this.ownerPhone,
    required this.amount,
    required this.type,
    this.referenceId,
    this.notes = '',
    required this.timestamp,
  });

  DepositTransaction copyWith({
    int? id,
    String? ownerPhone,
    double? amount,
    TransactionType? type,
    int? referenceId,
    String? notes,
    int? timestamp,
  }) {
    return DepositTransaction(
      id: id ?? this.id,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      notes: notes ?? this.notes,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerPhone': ownerPhone,
      'amount': amount,
      'type': type.value,
      'referenceId': referenceId,
      'notes': notes,
      'timestamp': timestamp,
    };
  }

  factory DepositTransaction.fromMap(Map<String, dynamic> map) {
    return DepositTransaction(
      id: (map['id'] as num?)?.toInt() ?? 0,
      ownerPhone: map['ownerPhone'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.fromString(map['type'] as String?),
      referenceId: (map['referenceId'] as num?)?.toInt(),
      notes: map['notes'] as String? ?? '',
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
    );
  }
}
