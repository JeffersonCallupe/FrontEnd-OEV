import 'package:flutter/material.dart';
import 'package:oev_mobile_app/domain/entities/dto/course_enrolled.dart';
import 'package:oev_mobile_app/domain/entities/lesson/lesson_progress_model.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/courses_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CourseContent extends ConsumerWidget {
  final CourseEnrolled courseEnrolled;

  const CourseContent({super.key, required this.courseEnrolled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsyncValue =
        ref.watch(lessonsByUserIdAndCourseIdProvider(courseEnrolled.courseId));

    return Scaffold(
      backgroundColor: const Color(0xff1E1E2C), // 🎨 Fondo oscuro
      appBar: AppBar(
        backgroundColor: const Color(0xff1E1E2C), // Color de la AppBar
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📸 Imagen del curso
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  courseEnrolled.courseImageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // 📜 Información del curso
              Text(
                courseEnrolled.courseName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Texto en blanco
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Instructor: ${courseEnrolled.instructorName}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70, // Texto gris claro
                    ),
                  ),
                  IconButton(
                    onPressed: () => ref.refresh(
                        lessonsByUserIdAndCourseIdProvider(
                            courseEnrolled.courseId)),
                    icon:
                        const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 📊 Progreso del curso
              Text(
                'Progreso: ${courseEnrolled.progress}%',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white, // Texto en blanco
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: courseEnrolled.progress / 100,
                backgroundColor:
                    Colors.grey[700], // Fondo gris oscuro para barra
                color: Colors.blueAccent, // Color del progreso
                minHeight: 8,
              ),
              const SizedBox(
                height: 10.0,
              ),
              lessonsAsyncValue.when(
                data: (lessons) => SizedBox(
                  height: 440, // Set a fixed height for the ListView
                  child: ListView.builder(
                    itemCount: lessons.length,
                    itemBuilder: (context, index) {
                      return LessonCard(
                          lesson: lessons[index], index: index + 1);
                    },
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final LessonProgress lesson;
  final int index;

  const LessonCard({super.key, required this.lesson, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(
          lesson.status == 'COMPLETED'
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
          color: lesson.status == 'COMPLETED' ? Colors.green : Colors.white,
        ),
        title: Text(
          "Clase $index: ${lesson.lessonTitle}",
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Text(
          '10:00',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
