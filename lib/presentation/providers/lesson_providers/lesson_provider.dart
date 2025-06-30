import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/lesson/lesson_model.dart';
import 'package:oev_mobile_app/domain/repositories/lesson_repository.dart';
import 'package:oev_mobile_app/infrastructure/repositories/lesson_repository_impl.dart';

final lessonRepositoryProvider = Provider<LessonRepository>((ref) {
  return LessonRepositoryImpl();
});

final lessonProvider = FutureProvider.autoDispose.family<List<Lesson>, int>((ref, courseId) async {
  final repository = ref.watch(lessonRepositoryProvider);
  return repository.getLessonsByCourseId(courseId);
});

final lessonDeleteProvider = FutureProvider.autoDispose.family<void, int>((ref, lessonId) async {
  final repository = ref.watch(lessonRepositoryProvider);
  return repository.deleteLessonById(lessonId);
});
