enum NotificationType { appointment, vitamin, vaccination, growth }
 
class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;           
  final String body;            
  final DateTime createdAt;
  final bool isRead;            
 
  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
  });
 
  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      type: type,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,           
      'title': title,
      'body': body,
      'createdAt': createdAt.toIso8601String(),  
      'isRead': isRead,
    };
  }
 
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: (json['id'] as String?) ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
      type: _parseType(json['type'] as String? ?? ''),
      title: (json['title'] as String?) ?? 'Notification',
      body: (json['body'] as String?) ?? '',
      createdAt: _parseDate(json['createdAt'] as String? ?? ''),
      isRead: (json['isRead'] as bool?) ?? false,
    );
  }
 
  static NotificationType _parseType(String value) {
    for (final t in NotificationType.values) {
      if (t.name == value) return t;
    }
    return NotificationType.growth; 
  }
 
  static DateTime _parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return DateTime.now();
    }
  }
 
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays} days ago';
  }
}