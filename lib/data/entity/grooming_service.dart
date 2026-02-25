class GroomingService {
  final int id;
  final String serviceName;
  final int defaultPrice;

  const GroomingService({
    this.id = 0,
    this.serviceName = '',
    this.defaultPrice = 0,
  });

  GroomingService copyWith({
    int? id,
    String? serviceName,
    int? defaultPrice,
  }) {
    return GroomingService(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      defaultPrice: defaultPrice ?? this.defaultPrice,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'serviceName': serviceName,
      'defaultPrice': defaultPrice,
    };
    if (id != 0) {
      map['id'] = id;
    }
    return map;
  }

  factory GroomingService.fromMap(Map<String, dynamic> map) {
    return GroomingService(
      id: (map['id'] as num?)?.toInt() ?? 0,
      serviceName: map['serviceName'] as String? ?? '',
      defaultPrice: (map['defaultPrice'] as num?)?.toInt() ?? 0,
    );
  }
}
