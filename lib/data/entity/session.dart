import 'dart:convert';

class Session {
  final int sessionId;
  final int catId;
  final int timestamp;
  final List<String> findings;
  final List<String> treatment;
  final List<String> bodyMapAreas;
  final String productsUsed;
  final String groomerNotes;
  final int totalCost;
  final String status; // "DONE", "WAITING", "BATHING", "DRYING", "FINISHING", "PICKUP_READY"
  final String? trackingToken;
  final int updatedAt;

  const Session({
    this.sessionId = 0,
    required this.catId,
    required this.timestamp,
    this.findings = const [],
    this.treatment = const [],
    this.bodyMapAreas = const [],
    this.productsUsed = '',
    this.groomerNotes = '',
    this.totalCost = 0,
    this.status = 'DONE',
    this.trackingToken,
    this.updatedAt = 0,
  });

  Session copyWith({
    int? sessionId,
    int? catId,
    int? timestamp,
    List<String>? findings,
    List<String>? treatment,
    List<String>? bodyMapAreas,
    String? productsUsed,
    String? groomerNotes,
    int? totalCost,
    String? status,
    String? trackingToken,
    int? updatedAt,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      catId: catId ?? this.catId,
      timestamp: timestamp ?? this.timestamp,
      findings: findings ?? this.findings,
      treatment: treatment ?? this.treatment,
      bodyMapAreas: bodyMapAreas ?? this.bodyMapAreas,
      productsUsed: productsUsed ?? this.productsUsed,
      groomerNotes: groomerNotes ?? this.groomerNotes,
      totalCost: totalCost ?? this.totalCost,
      status: status ?? this.status,
      trackingToken: trackingToken ?? this.trackingToken,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'catId': catId,
      'timestamp': timestamp,
      'findings': jsonEncode(findings),
      'treatment': jsonEncode(treatment),
      'bodyMapAreas': jsonEncode(bodyMapAreas),
      'productsUsed': productsUsed,
      'groomerNotes': groomerNotes,
      'totalCost': totalCost,
      'status': status,
      'trackingToken': trackingToken,
      'updatedAt': updatedAt,
    };
    if (sessionId != 0) {
      map['sessionId'] = sessionId;
    }
    return map;
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      sessionId: (map['sessionId'] as num?)?.toInt() ?? (map['id'] as num?)?.toInt() ?? (map['_id'] as num?)?.toInt() ?? (map['ID'] as num?)?.toInt() ?? (map['Id'] as num?)?.toInt() ?? 0,
      catId: (map['catId'] as num?)?.toInt() ?? 0,
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      findings: _decodeStringList(map['findings']),
      treatment: _decodeStringList(map['treatment']),
      bodyMapAreas: _decodeStringList(map['bodyMapAreas']),
      productsUsed: map['productsUsed'] as String? ?? '',
      groomerNotes: map['groomerNotes'] as String? ?? '',
      totalCost: (map['totalCost'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'DONE',
      trackingToken: map['trackingToken'] as String?,
      updatedAt: (map['updatedAt'] as num?)?.toInt() ?? 0,
    );
  }

  /// Decode a JSON-encoded string list, or return empty list on failure.
  static List<String> _decodeStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.cast<String>();
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return decoded.cast<String>();
      } catch (_) {}
    }
    return [];
  }
}
