class Lesson {
  final int id;
  final String title;
  final String videoKey;
  final int? duration;
  final int? sequenceOrder;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int courseId;

  Lesson({
    required this.id,
    required this.title,
    required this.videoKey,
    this.duration,
    this.sequenceOrder,
    required this.createdAt,
    this.updatedAt,
    required this.courseId,
  });

  static Lesson fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      videoKey: json['videoKey'],
      duration: json['duration'],
      sequenceOrder: json['sequenceOrder'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      courseId: json['courseId'],
    );
  }
}
