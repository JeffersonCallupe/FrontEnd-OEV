import 'package:oev_mobile_app/domain/entities/course/course_model.dart';

class CourseMapper {
  static Course userJsonToEntity(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      benefits: json['benefits'] ?? '',
      targetAudience: json['targetAudience'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? 'No category',
      level: json['level'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      duration: json['duration'] ?? 0,
      totalLessons: json['totalLessons'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      favorite: json['favorite'] ?? 0,
      status: json['status'] ?? '',
      creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate']) : DateTime.now(),
      lastUpdate: json['lastUpdate'] != null ? DateTime.parse(json['lastUpdate']) : DateTime.now(),
      userId: json['userId'],
      instructorName: json['instructorName'] ?? 'Instructor Name',
    );
  }
}
