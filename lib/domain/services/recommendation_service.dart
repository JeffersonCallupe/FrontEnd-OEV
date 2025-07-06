import 'dart:math';

import 'package:oev_mobile_app/domain/entities/course/course_model.dart';

class RecommendationService {
  // Implementación de KNN para recomendaciones
  List<Course> getTopRecommendedCourses(List<Course> allCourses, {int k = 5}) {
    if (allCourses.isEmpty) return [];

    // Normalizar los valores de estudiantes para el algoritmo KNN
    final maxStudents = allCourses.map((c) => c.totalStudents ?? 0).reduce(max);
    final features = allCourses
        .map((course) => {
              'normalizedStudents': (course.totalStudents ?? 0) / (maxStudents > 0 ? maxStudents : 1),
              'course': course,
            })
        .toList();

    // Ordenar por similitud (en este caso, por cantidad normalizada de estudiantes)
    features.sort((a, b) => (b['normalizedStudents'] as double).compareTo(a['normalizedStudents'] as double));

    // Retornar los top k cursos
    return features.take(k).map((f) => f['course'] as Course).toList();
  }
}