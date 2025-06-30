import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/conferences_providers/conferences_provider.dart';
import 'package:oev_mobile_app/presentation/widgets/conference/conference_card.dart';
import 'package:go_router/go_router.dart';

// Provider para almacenar el término de búsqueda
final searchQueryProvider = StateProvider<String>((ref) => "");

class ConferenceList extends ConsumerWidget {
  const ConferenceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final asyncConferences = ref.watch(conferenceProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final loggedUser = ref.read(authProvider).token;
    final isAdmin = loggedUser!.role == 'ADMIN';

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          'Conferencias',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const Text(
          'Conoce las conferencias disponibles',
          style: TextStyle(color: Colors.white70),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          child: SizedBox(
            width: 420,
            child: TextField(
              cursorColor: colors.primary,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).update((state) => value);
              },
              style: const TextStyle(color: Colors.white),
              onTapOutside: (event) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                hintText: 'Buscar por conferencia',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Color(0xff343646),
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
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => {
                      ref.refresh(conferenceProvider),
                    },
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 20),
                child: Visibility(
                  visible: isAdmin,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/conference/create');
                    },
                    child: const Row(
                      children: [Text('Crear Conferencia'), Icon(Icons.add)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: asyncConferences.when(
            data: (conferences) {
              // Filtrar los cursos según el término de búsqueda
              final filteredConferences = conferences.where((conference) => conference.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 4 / 4.4,
                  ),
                  itemCount: filteredConferences.length,
                  itemBuilder: (context, index) {
                    return ConferenceCard(conference: filteredConferences[index]);
                  },
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
