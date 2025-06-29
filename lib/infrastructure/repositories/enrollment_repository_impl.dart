import 'package:oev_mobile_app/domain/datasources/enrollment_datasource.dart';
import 'package:oev_mobile_app/domain/repositories/enrollment_repository.dart';

class EnrollmentRepositoryImpl implements EnrollmentRepository {
  final EnrollmentDatasource dataSource;

  EnrollmentRepositoryImpl({required this.dataSource});

  @override
  Future<bool> enrollUserInCourse(int userId, int courseId) async {
    return dataSource.enrollUserInCourse(userId, courseId);
  }

  @override
  Future<List<Map<String, dynamic>>> findEnrolledUsersByCourseId(int courseId) {
    return dataSource.findEnrolledUsersByCourseId(courseId);
  }

  @override
  Future<void> deleteEnrollmentById(int enrollmentId) {
    return dataSource.deleteEnrollmentById(enrollmentId);
  }
}