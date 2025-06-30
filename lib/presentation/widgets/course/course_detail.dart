import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/course/course_model.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/course_repository_provider.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/courses_provider.dart';
import 'package:oev_mobile_app/presentation/providers/lesson_providers/lesson_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/enrollment_providers/enrollment_provider.dart';

class CourseDetailPage extends ConsumerWidget {
  final int courseId;

  const CourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseByIdProvider(courseId));
    final loggedUser = ref.read(authProvider).token;
    final isInstructor = loggedUser?.role == 'INSTRUCTOR';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isInstructor)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () =>
                  _showEditCourseDialog(context, ref, courseAsync.value),
            ),
        ],
      ),
      body: courseAsync.when(
        data: (course) => _buildCourseDetail(context, ref, course),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text("Error: $err", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildCourseDetail(
      BuildContext context, WidgetRef ref, Course course) {
    final loggedUser = ref.read(authProvider).token;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              course.imageUrl ?? '',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),

          // Nombre del curso
          Text(
            course.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),

          // Fila con cantidad de alumnos, costo y favoritos
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.people, color: Colors.white70),
                    const SizedBox(height: 5),
                    Text("${course.totalStudents}",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.attach_money, color: Colors.white70),
                    const SizedBox(height: 5),
                    Text("S/. ${course.price}",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.favorite, color: Colors.redAccent),
                    const SizedBox(height: 5),
                    Text("${course.favorite}",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Nombre del instructor
          Text(
            "Docente: ${course.instructorName}",
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),

          // Botón de Inscribirse
          Visibility(
            visible: loggedUser?.role == 'STUDENT',
            child: Center(
              child: ElevatedButton(
                onPressed: () =>
                    _showEnrollmentConfirmation(context, ref, course.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Inscribirse',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sección de Descripción
          _buildSection("Descripción", course.description),
          const SizedBox(height: 16),

          // Sección "Lo que aprenderás"
          _buildSection("Lo que aprenderás", course.benefits),
          const SizedBox(height: 16),

          // Sección "¿Para quién es este curso?"
          _buildSection("¿Para quién es este curso?", course.targetAudience),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Confirmation Modal
  void _showEnrollmentConfirmation(
      BuildContext context, WidgetRef ref, int courseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242636),
          title: const Text('Confirmación',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold)),
          content: const Text('¿Seguro que quieres inscribirte el curso?',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.normal)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                // Aquí puedes añadir tu lógica para agregar el curso a la cesta
                Navigator.of(context).pop(); // Cierra el diálogo
                _enrollUser(ref, courseId);
              },
              child: const Text('Aceptar',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // Enroll User Function
  void _enrollUser(WidgetRef ref, int courseId) {
    final userId = ref.read(authProvider).token?.id;
    if (userId == null) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    final enrollmentData = {'userId': userId, 'courseId': courseId};
    ref.read(enrollmentProvider(enrollmentData).future).then((success) {
      if (success) {
        // Show success message
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('Inscripción exitosa!')),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(ref.context).showSnackBar(
          const SnackBar(content: Text('Error al inscribirse')),
        );
      }
    }).catchError((error) {
      // Show error message
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

  Widget _buildSection(String title, String? content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242636),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content ?? "No disponible.",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(
      BuildContext context, WidgetRef ref, Course? course) {
    if (course == null) return;

    final nameController = TextEditingController(text: course.name);
    final descriptionController =
        TextEditingController(text: course.description);
    final categoryController = TextEditingController(text: course.category);
    final benefitsController = TextEditingController(text: course.benefits);
    final targetAudienceController =
        TextEditingController(text: course.targetAudience);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242636),
          title: const Text('Editar Curso',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del curso',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: benefitsController,
                  decoration: const InputDecoration(
                    labelText: 'Lo que aprenderás',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: targetAudienceController,
                  decoration: const InputDecoration(
                    labelText: '¿Para quién es este curso?',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Cancelar',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.blue),
              ),
              onPressed: () {
                _updateCourse(
                    ref,
                    course.id,
                    nameController.text,
                    descriptionController.text,
                    categoryController.text,
                    benefitsController.text,
                    targetAudienceController.text);
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: const Text('Actualizar',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _updateCourse(
      WidgetRef ref,
      int courseId,
      String name,
      String description,
      String category,
      String benefits,
      String targetAudience) {
    final courseData = {
      "name": name,
      "description": description,
      "category": category,
      "benefits": benefits,
      "targetAudience": targetAudience
    };

    ref
        .read(courseRepositoryProvider)
        .updateCourse(courseId, courseData)
        .then((_) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text('Curso actualizado exitosamente!')),
      );
      // Usar el valor devuelto por refresh
      final updatedCourse = ref.refresh(courseByIdProvider(courseId));
      print(updatedCourse); // O hacer algo con el valor actualizado
    }).catchError((error) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el curso: $error')),
      );
    });
  }
}
