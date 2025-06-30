import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/conferences_providers/conferences_provider.dart';
import 'package:oev_mobile_app/presentation/widgets/conference/conference_card.dart';
import 'package:oev_mobile_app/presentation/widgets/conference/registered_conferences_screen.dart';
import 'package:oev_mobile_app/presentation/widgets/conference/conference_creation.dart';
import 'package:oev_mobile_app/presentation/widgets/conference/user_conferences_screen.dart';

// Provider para almacenar el término de búsqueda
final searchQueryProvider = StateProvider<String>((ref) => "");

// Provider para almacenar la categoría seleccionada
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

class ConferenceList extends ConsumerWidget {
  const ConferenceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final asyncConferences = ref.watch(conferenceProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final loggedUser = ref.read(authProvider).token;
    final userRole = loggedUser!.role;
    final isAdmin = userRole == 'ADMIN';
    final canSeeRegistered =
        userRole == 'STUDENT' || userRole == 'ADMINISTRATIVE';

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Conferencias',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Text(
              'Conoce las conferencias disponibles',
              style: TextStyle(color: Colors.white70),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: 420,
                      child: TextField(
                        cursorColor: colors.primary,
                        onChanged: (value) {
                          ref
                              .read(searchQueryProvider.notifier)
                              .update((state) => value);
                        },
                        style: const TextStyle(color: Colors.white),
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        decoration: const InputDecoration(
                          hintText: 'Buscar por conferencia',
                          hintStyle: TextStyle(color: Colors.grey),
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Color(0xff343646),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      _showCategoryFilterDialog(context, ref);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Conferencias',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: () => {
                          ref.refresh(conferenceProvider),
                        },
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, right: 20),
                    child: Row(
                      children: [
                        Visibility(
                          visible: isAdmin,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CreateConferenceScreen(),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text('Crear Conferencia'),
                                Icon(Icons.add)
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Visibility(
                          visible: canSeeRegistered,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisteredConferencesScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 255, 255, 255)),
                            child: const Row(
                              children: [Text('Inscripciones')],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: asyncConferences.when(
                data: (conferences) {
                  // Filtrar conferencias por búsqueda y categoría
                  final filteredConferences = conferences
                      .where((conference) =>
                          conference.name
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) &&
                          (selectedCategory == null ||
                              conference.category == selectedCategory))
                      .toList();

                  if (filteredConferences.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay conferencias publicadas',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 4 / 4.4,
                      ),
                      itemCount: filteredConferences.length,
                      itemBuilder: (context, index) {
                        return ConferenceCard(
                            conference: filteredConferences[index]);
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),

        // Botón flotante en la parte inferior derecha
        Positioned(
          bottom: 16,
          right: 16,
          child: Visibility(
            visible: isAdmin,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserConferencesScreen(),
                  ),
                );
              },
              label: const Text("Mis Conferencias"),
              icon: const Icon(Icons.event_note),
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
      ],
    );
  }

  void _showCategoryFilterDialog(BuildContext context, WidgetRef ref) {
    // Lista de categorías predefinidas
    final List<String> categories = [
      'Innovación y Tecnología',
      'Investigación y Desarrollo Académico',
      'Empleabilidad y Desarrollo Profesional',
      'Ciencia',
    ];

    // Categoría seleccionada actualmente
    final selectedCategory = ref.read(selectedCategoryProvider);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242636),
          title: const Text('Filtrar por categoría',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ...categories.map((category) {
                  return ListTile(
                    title: Text(category,
                        style: const TextStyle(color: Colors.white)),
                    trailing: selectedCategory == category
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                    onTap: () {
                      ref.read(selectedCategoryProvider.notifier).state =
                          category;
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
                if (selectedCategory != null)
                  TextButton(
                    onPressed: () {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      Navigator.pop(context);
                    },
                    child: const Text('Limpiar filtro',
                        style: TextStyle(color: Colors.blue)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
