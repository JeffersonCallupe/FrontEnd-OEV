import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/course/course_model.dart';
import 'package:oev_mobile_app/domain/entities/dto/course_enrolled.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/course_dto.dart';
import 'package:oev_mobile_app/domain/entities/lesson/lesson_progress_model.dart';
import 'package:oev_mobile_app/domain/repositories/course_repository.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/course_repository_provider.dart';

final coursesProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.getCourses();
});

final coursesPublishedByInstructorProvider =
    FutureProvider.autoDispose<List<Course>>((ref) async {
  final repository = ref.watch(courseRepositoryProvider);
  final auth = ref.watch(authProvider);
  return repository.getCoursesPublishedByInstructor(auth.token!.id);
});

final courseByIdProvider =
    FutureProvider.family.autoDispose<Course, int>((ref, courseId) async {
  final repository = ref.watch(courseRepositoryProvider);
  return repository.getCourseById(courseId);
});

final enrolledCoursesProvider =
    FutureProvider.autoDispose<List<CourseEnrolled>>((ref) async {
  final repository = ref.watch(courseRepositoryProvider);
  final auth = ref.watch(authProvider);
  return repository.getEnrolledCourses(auth.token!.id);
});

final lessonsByUserIdAndCourseIdProvider = FutureProvider.family
    .autoDispose<List<LessonProgress>, int>((ref, courseId) async {
  final repository = ref.watch(courseRepositoryProvider);
  final auth = ref.watch(authProvider);
  return repository.getLessonsByUserIdAndCourseId(auth.token!.id, courseId);
});

final deleteCourseProvider =
    StateNotifierProvider<DeleteCourseNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(courseRepositoryProvider);
  return DeleteCourseNotifier(repository);
});

class DeleteCourseNotifier extends StateNotifier<AsyncValue<void>> {
  final CourseRepository repository;

  DeleteCourseNotifier(this.repository) : super(const AsyncData(null));

  Future<void> deleteCourse(int courseId) async {
    state = const AsyncLoading();
    try {
      await repository.deleteCourse(courseId);
      state = const AsyncData(null);
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
    }
  }
}

final addCourseProvider =
    StateNotifierProvider<AddCourseNotifier, AsyncValue<Course>>((ref) {
  final repository = ref.watch(courseRepositoryProvider);
  return AddCourseNotifier(repository);
});

class AddCourseNotifier extends StateNotifier<AsyncValue<Course>> {
  final CourseRepository repository;

  AddCourseNotifier(this.repository)
      : super(
            AsyncData(Course(id: 0, name: '', userId: 0, instructorName: '')));

  Future<Course> addCourse(
      int userId, CourseRequestDTO courseRequestDTO) async {
    state = const AsyncLoading();
    try {
      final course = await repository.addCourse(userId, courseRequestDTO);
      state = AsyncData(course);
      return course;
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
      rethrow;
    }
  }
}
