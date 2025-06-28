import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/course/course_model.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/screens/course/course_editable_content.dart';
import 'package:oev_mobile_app/presentation/widgets/course/course_detail.dart';

class CourseCard extends ConsumerWidget {
  final Course course;
  const CourseCard({required this.course, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedUser = ref.read(authProvider).token;

    final isAdmin = loggedUser?.role == 'ADMIN';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => isAdmin ? CourseEditableContent(course: course) : CourseDetailPage(courseId: course.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF32343E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 13,
            ),
            Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF32343E),
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    // image: AssetImage('assets/images/fisinext.png'),
                    image: NetworkImage(course.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(course.instructorName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Icon(Icons.people, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(course.totalStudents.toString(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}