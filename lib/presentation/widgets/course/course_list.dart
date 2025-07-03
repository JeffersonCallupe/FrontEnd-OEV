import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/courses_provider.dart';
import 'package:oev_mobile_app/presentation/widgets/course/course_card.dart';
import 'package:go_router/go_router.dart';

final searchQueryProvider = StateProvider<String>((ref) => "");
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// coment

class CourseList extends ConsumerWidget {
  const CourseList({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final asyncCourses = ref.watch(coursesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final loggedUser = ref.read(authProvider).token;

    ref.listen(authProvider, (previous, next) {
      ref.read(selectedCategoryProvider.notifier).state = null;
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, ${loggedUser?.name ?? 'User'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const Text(
              'Tenemos sugerencias para ti basadas en tus intereses',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              height: 180,
              child: Placeholder( // Placeholder for the recommended courses slider
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: colors.primary,
                    onChanged: (value) {
                      ref.read(searchQueryProvider.notifier).update((state) => value);
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
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: const Color(0xff1E1F29),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          title: const Text(
                            'Seleccionar categoría',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...['Tecnología y Programación', 'Negocios y Emprendimiento', 'Diseño', 'Ciencias y Matemáticas', 'Idiomas', 'Desarrollo Personal'].map((category) {
                                return ListTile(
                                  title: Text(category, style: const TextStyle(color: Colors.white)),
                                  onTap: () {
                                    ref.read(selectedCategoryProvider.notifier).state = category;
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                    visible: loggedUser!.role == 'INSTRUCTOR',
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/course/create');
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [Text('Crear Curso'), Icon(Icons.add)],
                        ),
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 5),
            if (selectedCategory != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedCategory,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state = null;
                      },
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 15),
            asyncCourses.when(
              data: (courses) {
                final filteredCourses = courses.where((course) {
                  final matchesSearch = course.name.toLowerCase().contains(searchQuery.toLowerCase());
                  final matchesCategory = selectedCategory == null || course.category == selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filteredCourses.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay cursos publicados',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 4 / 4.4,
                  ),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    return CourseCard(course: filteredCourses[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }
}
