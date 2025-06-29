import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/course/course_model.dart';
import 'package:oev_mobile_app/domain/entities/dto/course_enrolled.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/courses_provider.dart';
import 'package:oev_mobile_app/presentation/providers/enrollment_providers/enrollment_provider.dart';
import 'package:oev_mobile_app/presentation/screens/course/course_content.dart';
import 'package:oev_mobile_app/presentation/screens/course/certificado.dart';
import 'package:oev_mobile_app/presentation/screens/course/course_editable_content.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");
final showCompletedProvider = StateProvider<bool>((ref) => false);

class MyCourses extends ConsumerWidget {
  const MyCourses({super.key});
 
@override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final enrolledCoursesAsync = ref.watch(enrolledCoursesProvider);
    final publishedCoursesAsync = ref.watch(coursesPublishedByInstructorProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final showCompleted = ref.watch(showCompletedProvider);
    final loggedUser = ref.read(authProvider).token;

    final bool isStudentOrAdmin = loggedUser!.role == 'STUDENT' || loggedUser.role == 'ADMINISTRATIVE';

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Sección de cursos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Text(
          'Continúa donde lo dejaste',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: SizedBox(
            width: 420,
            child: TextField(
              cursorColor: colors.primary,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              style: const TextStyle(color: Colors.white),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                hintText: 'Buscar por curso',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xff343646),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
              ),
            ),
          ),
        ),




}
