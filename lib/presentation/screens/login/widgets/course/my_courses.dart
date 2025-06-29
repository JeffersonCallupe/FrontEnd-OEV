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
    final publishedCoursesAsync =
        ref.watch(coursesPublishedByInstructorProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final showCompleted = ref.watch(showCompletedProvider);
    final loggedUser = ref.read(authProvider).token;

    final bool isStudentOrAdmin =
        loggedUser!.role == 'STUDENT' || loggedUser.role == 'ADMINISTRATIVE';

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Sección de cursos',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
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

// Mostrar el switch solo si el usuario es estudiante o administrativo
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Cursos',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => {
                  isStudentOrAdmin
                      ? ref.refresh(enrolledCoursesProvider)
                      : ref.refresh(coursesPublishedByInstructorProvider),
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
        if (isStudentOrAdmin) ...[
          SwitchListTile(
            title: const Text('Mostrar solo cursos completados',
                style: TextStyle(color: Colors.white)),
            value: showCompleted,
            onChanged: (value) =>
                ref.read(showCompletedProvider.notifier).state = value,
          ),
          if (showCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CertificateScreen(),
                  ),
                );
              },
              child: const Text('Ver lista de certificados'),
            ),
        ],
        Expanded(
          child: isStudentOrAdmin
              // --- Para ESTUDIANTE o ADMIN ---
              ? enrolledCoursesAsync.when(
                  data: (courses) {
                    var filteredCourses = courses
                        .where((course) =>
                            course.courseName
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()) &&
                            (!showCompleted || course.progress == 100))
                        .toList();
                    if (filteredCourses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay cursos inscritos',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 4 / 4.6,
                      ),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          // onTap: () => context.push('/course_content', extra: filteredCourses[index]),
                          child: EnrolledCourseCard(
                              enrolledCourse: filteredCourses[index]),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                )
              // --- Para INSTRUCTOR ---
              : publishedCoursesAsync.when(
                  data: (courses) {
                    final filteredCourses = courses
                        .where((course) => course.name
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();
                    if (filteredCourses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay cursos publicados',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    return SizedBox(
                      height: 440, // Ajusta la altura según necesidad
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 4 / 4.2,
                          ),
                          itemCount: filteredCourses.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseEditableContent(
                                        course: filteredCourses[index]),
                                  ),
                                );
                              },
                              child: PublishedCourseCard(
                                  publishedCourse: filteredCourses[index]),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
        ),
      ],
    );
  }
}
