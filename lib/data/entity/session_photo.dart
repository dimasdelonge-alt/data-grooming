enum PhotoType {
  before,
  finding,
  after;

  String get value {
    switch (this) {
      case PhotoType.before:
        return 'BEFORE';
      case PhotoType.finding:
        return 'FINDING';
      case PhotoType.after:
        return 'AFTER';
    }
  }

  static PhotoType fromString(String? value) {
    switch (value) {
      case 'FINDING':
        return PhotoType.finding;
      case 'AFTER':
        return PhotoType.after;
      case 'BEFORE':
      default:
        return PhotoType.before;
    }
  }
}

class SessionPhoto {
  final int photoId;
  final int sessionId;
  final PhotoType type;
  final String filePath;

  const SessionPhoto({
    this.photoId = 0,
    this.sessionId = 0,
    this.type = PhotoType.before,
    this.filePath = '',
  });

  SessionPhoto copyWith({
    int? photoId,
    int? sessionId,
    PhotoType? type,
    String? filePath,
  }) {
    return SessionPhoto(
      photoId: photoId ?? this.photoId,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photoId': photoId,
      'sessionId': sessionId,
      'type': type.value,
      'filePath': filePath,
    };
  }

  factory SessionPhoto.fromMap(Map<String, dynamic> map) {
    return SessionPhoto(
      photoId: map['photoId'] as int? ?? 0,
      sessionId: map['sessionId'] as int? ?? 0,
      type: PhotoType.fromString(map['type'] as String?),
      filePath: map['filePath'] as String? ?? '',
    );
  }
}
