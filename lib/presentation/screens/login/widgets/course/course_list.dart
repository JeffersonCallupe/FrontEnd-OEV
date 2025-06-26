import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/widgets/course/recommended_courses_slider.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class CourseList extends ConsumerWidget {
  const CourseList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedUser = ref.read(authProvider).token;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👋 Bienvenida
            Text(
              'Bienvenido, ${loggedUser?.name ?? 'Usuario'}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Tenemos sugerencias para ti basadas en tus intereses',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // 🎞️ Carrusel de cursos recomendados
            const SizedBox(
              height: 180,
              child: RecommendedCoursesSlider(),
            ),
          ],
        ),
      ),
    );
  }
}
