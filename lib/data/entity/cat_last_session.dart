class CatLastSession {
  final int catId;
  final int lastDate;

  const CatLastSession({
    required this.catId,
    required this.lastDate,
  });

  factory CatLastSession.fromMap(Map<String, dynamic> map) {
    return CatLastSession(
      catId: map['catId'] as int? ?? 0,
      lastDate: map['lastDate'] as int? ?? 0,
    );
  }
}
