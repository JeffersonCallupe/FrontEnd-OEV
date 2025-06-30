class Conference {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? category;
  final int? totalStudents;
  final String? status;
  final DateTime? creationDate;
  final DateTime? lastUpdate;
  final DateTime date;
  final int userId;
  final String creatorName;

  Conference({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.category,
    this.totalStudents,
    this.status,
    this.creationDate,
    this.lastUpdate,
    required this.date,
    required this.userId,
    required this.creatorName,
  });
}
