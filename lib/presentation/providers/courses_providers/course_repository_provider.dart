import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/repositories/course_repository.dart';
import 'package:oev_mobile_app/infrastructure/repositories/course_repository_impl.dart';

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepositoryImpl();
});