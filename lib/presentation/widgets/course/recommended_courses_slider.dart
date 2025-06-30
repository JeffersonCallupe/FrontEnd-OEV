// lib/presentation/widgets/course/recommended_courses_slider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/courses_provider.dart';
import 'package:oev_mobile_app/presentation/widgets/course/course_detail.dart';

class RecommendedCoursesSlider extends ConsumerWidget {
  const RecommendedCoursesSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendedCourses = ref.watch(recommendedCoursesProvider);

    return recommendedCourses.when(
      data: (courses) {
        if (courses.isEmpty) {
          return const SizedBox.shrink();
        }

        final limitedCourses = courses.length >= 3 ? courses.take(3).toList() : courses;

        return SizedBox(
          height: 180,
          child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              final course = limitedCourses[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseDetailPage(courseId: course.id),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(course.imageUrl ?? 'https://via.placeholder.com/400x320'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                course.instructorName,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.people,
                                size: 16,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.totalStudents ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            itemCount: limitedCourses.length,
            pagination: const SwiperPagination(
              builder: DotSwiperPaginationBuilder(
                activeColor: Colors.white,
                color: Colors.white54,
              ),
            ),
            autoplay: true,
            autoplayDelay: 3000,
            duration: 800,
            viewportFraction: 0.8,
            scale: 0.9,
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
