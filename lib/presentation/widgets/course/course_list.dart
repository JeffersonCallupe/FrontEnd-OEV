// Importación de paquetes necesarios
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/courses_provider.dart';
import 'package:oev_mobile_app/presentation/widgets/course/course_card.dart';

// Provider que guarda el texto de búsqueda del usuario
final searchQueryProvider = StateProvider<String>((ref) => "");

// Provider que guarda la categoría seleccionada (puede ser null si no se ha seleccionado ninguna)
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Widget principal que consume providers
class CourseList extends ConsumerWidget {
  const CourseList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtiene la paleta de colores del tema actual
    final colors = Theme.of(context).colorScheme;

    // Observa el estado asincrónico de los cursos
    final asyncCourses = ref.watch(coursesProvider);

    // Observa el valor actual del texto de búsqueda
    final searchQuery = ref.watch(searchQueryProvider);

    // Observa la categoría seleccionada
    final selectedCategory = ref.watch(selectedCategoryProvider);

    // Obtiene el usuario autenticado (token y datos)
    final loggedUser = ref.read(authProvider).token;

    // Reinicia la categoría seleccionada cuando cambia el estado de autenticación
    ref.listen(authProvider, (previous, next) {
      ref.read(selectedCategoryProvider.notifier).state = null;
    });

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Muestra mensaje de bienvenida con el nombre del usuario logueado
            Text(
              'Bienvenido, ${loggedUser?.name ?? 'User'}',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),

            // Mensaje secundario
            const Text(
              'Tenemos sugerencias para ti basadas en tus intereses',
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            // Fila con campo de búsqueda y botón de filtro
            Row(
              children: [
                // Campo de texto para buscar cursos
                Expanded(
                  child: TextField(
                    cursorColor: colors.primary,
                    onChanged: (value) {
                      // Actualiza el valor del texto de búsqueda en el provider
                      ref
                          .read(searchQueryProvider.notifier)
                          .update((state) => value);
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

                // Botón que abre el cuadro de diálogo de selección de categoría
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
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          // Lista de categorías disponibles
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...[
                                'Tecnología y Programación',
                                'Negocios y Emprendimiento',
                                'Diseño',
                                'Ciencias y Matemáticas',
                                'Idiomas',
                                'Desarrollo Personal'
                              ].map((category) {
                                return ListTile(
                                  title: Text(category,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  onTap: () {
                                    // Establece la categoría seleccionada en el provider
                                    ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state = category;
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

            // Si hay una categoría seleccionada, se muestra como un "chip" con opción de quitarla
            if (selectedCategory != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Nombre de la categoría
                    Text(
                      selectedCategory,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    // Botón para quitar el filtro
                    GestureDetector(
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            null;
                      },
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 15),

            // Sección que muestra los cursos (dependiendo del estado del provider)
            asyncCourses.when(
              data: (courses) {
                // Filtrado de cursos por búsqueda y categoría
                final filteredCourses = courses.where((course) {
                  final matchesSearch = course.name
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());

                  final matchesCategory = selectedCategory == null ||
                      course.category == selectedCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                // Si no hay cursos luego de filtrar
                if (filteredCourses.isEmpty) {
                  return const Center(
                    child: Text(
                      'No hay cursos publicados',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }

                // Muestra los cursos filtrados como tarjetas en una grilla
                return GridView.builder(
                  shrinkWrap: true, // Evita que ocupe toda la pantalla
                  physics:
                      const NeverScrollableScrollPhysics(), // Desactiva scroll interno
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 columnas
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio:
                        4 / 4.4, // Tamaño relativo de las tarjetas
                  ),
                  itemCount: filteredCourses.length,
                  itemBuilder: (context, index) {
                    return CourseCard(course: filteredCourses[index]);
                  },
                );
              },
              // Mientras se carga, muestra un spinner
              loading: () => const Center(child: CircularProgressIndicator()),

              // Si hay error, lo muestra en pantalla
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }
}
