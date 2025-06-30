import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/course/course_model.dart';
import 'package:oev_mobile_app/domain/services/recommendation_service.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/courses_provider.dart';

final recommendationServiceProvider = Provider((ref) => RecommendationService());

final recommendedCoursesProvider = FutureProvider<List<Course>>((ref) async {
  final allCourses = await ref.watch(coursesProvider.future);
  final recommendationService = ref.watch(recommendationServiceProvider);
  return recommendationService.getTopRecommendedCourses(allCourses);
});