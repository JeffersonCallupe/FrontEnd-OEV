class Course {
  final int id;
  final String name;
  final String? description;
  final String? benefits;
  final String? targetAudience;
  final String? imageUrl;
  final String? category;
  final String? level;
  final double? price;
  final int? duration;
  final int? totalLessons;
  final int? totalStudents;
  final int? favorite;
  final String? status;
  final DateTime? creationDate;
  final DateTime? lastUpdate;
  final int userId;

  Course({
    required this.id,
    required this.name,
    this.description,
    this.benefits,
    this.targetAudience,
    this.imageUrl,
    this.category,
    this.level,
    this.price,
    this.duration,
    this.totalLessons,
    this.totalStudents,
    this.favorite,
    this.status,
    this.creationDate,
    this.lastUpdate,
    required this.userId,
  });
}
