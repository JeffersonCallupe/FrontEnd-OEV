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

        // Mostrar el switch solo si el usuario es estudiante o administrativo
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Cursos',
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => {
                  isStudentOrAdmin ? ref.refresh(enrolledCoursesProvider) : ref.refresh(coursesPublishedByInstructorProvider),
                },
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              ),
            ],
          ),
        ),
        if (isStudentOrAdmin) ...[
          SwitchListTile(
            title: const Text('Mostrar solo cursos completados', style: TextStyle(color: Colors.white)),
            value: showCompleted,
            onChanged: (value) => ref.read(showCompletedProvider.notifier).state = value,
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
                    var filteredCourses = courses.where((course) => course.courseName.toLowerCase().contains(searchQuery.toLowerCase()) && (!showCompleted || course.progress == 100)).toList();
                    if (filteredCourses.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay cursos inscritos',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 4 / 4.6,
                      ),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          // onTap: () => context.push('/course_content', extra: filteredCourses[index]),
                          child: EnrolledCourseCard(enrolledCourse: filteredCourses[index]),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                )
              // --- Para INSTRUCTOR ---
              : publishedCoursesAsync.when(
                  data: (courses) {
                    final filteredCourses = courses.where((course) => course.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    builder: (context) => CourseEditableContent(course: filteredCourses[index]),
                                  ),
                                );
                              },
                              child: PublishedCourseCard(publishedCourse: filteredCourses[index]),
                            );
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Error: $error')),
                ),
        ),
      ],
    );
  }
}

// --- Tarjeta de cursos PUBLICADOS por el instructor ---
class PublishedCourseCard extends StatelessWidget {
  final Course publishedCourse;

  const PublishedCourseCard({required this.publishedCourse, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del curso
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                publishedCourse.imageUrl!,
                width: double.infinity,
                height: 130,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),

            // Nombre del curso
            Text(
              publishedCourse.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Instructor del curso
            Text(
              publishedCourse.instructorName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Tarjeta de cursos ENROLADOS por el estudiante ---
class EnrolledCourseCard extends ConsumerWidget {
  final CourseEnrolled enrolledCourse;

  const EnrolledCourseCard({required this.enrolledCourse, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseContent(courseEnrolled: enrolledCourse),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del curso
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    enrolledCourse.courseImageUrl,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                // Nombre del curso
                Text(
                  enrolledCourse.courseName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Nombre del instructor
                Text(
                  enrolledCourse.instructorName,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                // Progreso del curso
                LinearProgressIndicator(
                  value: enrolledCourse.progress / 100,
                  backgroundColor: Colors.grey,
                  color: Colors.blue,
                  minHeight: 5,
                ),
                const SizedBox(height: 4),
                // Texto del progreso
                Text(
                  'Progreso: ${enrolledCourse.progress}%',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        // Botón de eliminación (X) en la esquina superior derecha
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: const Color(0xFF242636),
                    title: const Text('Confirmar', style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold)),
                    content: const Text(
                      '¿Estás seguro de que deseas eliminar tu inscripción a este curso?',
                      style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.normal),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontSize: 14.0, fontWeight: FontWeight.bold)),
                      ),
                      FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text(
                          'Aceptar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirm ?? false) {
                await ref.read(enrollmentDeleteProvider(enrolledCourse.id).future);
                // Invalida el provider que recarga la lista de cursos inscritos
                ref.invalidate(enrolledCoursesProvider);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inscripción eliminada correctamente')),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}