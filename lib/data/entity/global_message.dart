class GlobalMessage {
  final String id;
  final bool isActive;
  final String title;
  final String body;
  final bool dismissible;

  GlobalMessage({
    required this.id,
    required this.isActive,
    required this.title,
    required this.body,
    required this.dismissible,
  });

  factory GlobalMessage.fromMap(Map<String, dynamic> map) {
    return GlobalMessage(
      id: map['id']?.toString() ?? 'unknown_id',
      isActive: map['isActive'] == true,
      title: map['title']?.toString() ?? 'Message',
      body: map['body']?.toString() ?? '',
      dismissible: map['dismissible'] != false, // Default to true if not provided
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isActive': isActive,
      'title': title,
      'body': body,
      'dismissible': dismissible,
    };
  }
}
