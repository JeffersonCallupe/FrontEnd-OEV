import 'package:oev_mobile_app/domain/entities/course/course_model.dart';
import 'package:oev_mobile_app/domain/entities/dto/course_enrolled.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/course_dto.dart';
import 'package:oev_mobile_app/domain/entities/lesson/lesson_progress_model.dart';

abstract class CourseRepository {
  Future<List<Course>> getCourses();
  Future<List<CourseEnrolled>> getEnrolledCourses(int userId);
  Future<Course> addCourse(int userId, CourseRequestDTO courseRequestDTO);
  Future<Course> getCourseById(int courseId);
  Future<List<Course>> getCoursesPublishedByInstructor(int userId);
  Future<List<LessonProgress>> getLessonsByUserIdAndCourseId(int userId, int courseId);
  Future<void> deleteCourse(int courseId);
  Future<List<Course>> getRecommendedCourses();
}