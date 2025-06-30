class CourseEnrolled {
  final int id;
  final int userId;
  final int courseId;
  final String status;
  final double progress;
  final String enrollmentDate;
  final String courseImageUrl;
  final String courseName;
  final String instructorName;

  CourseEnrolled(
      {required this.id,
      required this.userId,
      required this.courseId,
      required this.status,
      required this.progress,
      required this.enrollmentDate,
      required this.courseImageUrl,
      required this.courseName,
      required this.instructorName});

  static CourseEnrolled fromJson(Map<String, dynamic> json) {
    return CourseEnrolled(
        id: json['id'],
        userId: json['userId'],
        courseId: json['courseId'],
        status: json['status'],
        progress: json['progress'],
        enrollmentDate: json['enrollmentDate'],
        courseImageUrl: json['courseImageUrl'],
        courseName: json['courseName'],
        instructorName: json['instructorName']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'courseId': courseId,
      'status': status,
      'progress': progress,
      'enrollmentDate': enrollmentDate,
      'courseImageUrl': courseImageUrl,
      'courseName': courseName,
      'instructorName': instructorName
    };
  }

  @override
  String toString() {
    return 'CourseEnrolled{id: $id, userId: $userId, courseId: $courseId, status: $status, progress: $progress, enrollmentDate: $enrollmentDate, courseImageUrl: $courseImageUrl, courseName: $courseName, instructorName: $instructorName}';
  }
}
