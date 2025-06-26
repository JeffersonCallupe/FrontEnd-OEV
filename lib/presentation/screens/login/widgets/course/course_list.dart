import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/widgets/course/recommended_courses_slider.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");

class CourseList extends ConsumerWidget {
  const CourseList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
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
            const SizedBox(height: 20),

            // 🔍 Campo de búsqueda
            TextField(
              cursorColor: colors.primary,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Buscar por curso',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: Color(0xff2A2D3E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
