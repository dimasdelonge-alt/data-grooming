class ChipOption {
  final int id;
  final String category; // "finding" or "treatment"
  final String label;

  const ChipOption({
    this.id = 0,
    required this.category,
    required this.label,
  });

  ChipOption copyWith({
    int? id,
    String? category,
    String? label,
  }) {
    return ChipOption(
      id: id ?? this.id,
      category: category ?? this.category,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'category': category,
      'label': label,
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory ChipOption.fromMap(Map<String, dynamic> map) {
    return ChipOption(
      id: map['id'] as int? ?? 0,
      category: map['category'] as String? ?? '',
      label: map['label'] as String? ?? '',
    );
  }
}
