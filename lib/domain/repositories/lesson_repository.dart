import 'package:oev_mobile_app/domain/entities/lesson/lesson_model.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getLessonsByCourseId(int courseId);
  Future<Lesson> createLesson(int courseId, String title, String videoKey);
  Future<void> deleteLessonById(int lessonId);
}
