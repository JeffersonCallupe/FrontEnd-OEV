import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/conference/conference_model.dart';
import 'package:oev_mobile_app/presentation/providers/conferences_providers/conference_repository_provider.dart';
import 'package:oev_mobile_app/presentation/providers/conferences_providers/conferences_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_providers/registration_provider.dart';
import 'package:oev_mobile_app/presentation/screens/conference/conference_list_participants.dart';

final snackbarMessageProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

class ConferenceDetailPage extends ConsumerWidget {
  final int conferenceId;

  const ConferenceDetailPage({super.key, required this.conferenceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conferenceAsync = ref.watch(conferenceByIdProvider(conferenceId));
    final loggedUser = ref.read(authProvider).token;
    final isAdmin =
        loggedUser?.role == 'ADMIN'; // Verificar si el usuario es ADMIN

    ref.listen<Map<String, dynamic>?>(snackbarMessageProvider,
        (previous, next) {
      if (next != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(next['message'],
                    style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.blueAccent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            )
            .closed
            .then((_) {
          if (next['shouldPop'] == true) {
            Navigator.pop(context);
          }
        });
        ref.read(snackbarMessageProvider.notifier).state = null;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Ícono de edición solo para ADMIN
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                if (conferenceAsync.value != null) {
                  _showEditConferenceDialog(
                      context, ref, conferenceAsync.value!);
                }
              },
            ),
        ],
      ),
      body: conferenceAsync.when(
        data: (conference) => _buildCourseDetail(context, ref, conference),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text("Error: $err", style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildCourseDetail(
      BuildContext context, WidgetRef ref, Conference conference) {
    final loggedUser = ref.read(authProvider).token;
    final isVisible = loggedUser?.role == 'STUDENT' ||
        loggedUser?.role == 'ADMINISTRATIVE' ||
        loggedUser?.role == 'INSTRUCTOR';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              conference.imageUrl ?? '',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            conference.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.category, color: Colors.white70),
                    const SizedBox(height: 5),
                    Text("${conference.category}",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.people, color: Colors.white70),
                    const SizedBox(height: 5),
                    Text("${conference.totalStudents}",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Icon(Icons.update, color: Colors.white70),
                    const SizedBox(height: 5),
                    Text(
                      conference.lastUpdate != null
                          ? conference.lastUpdate!
                              .toLocal()
                              .toString()
                              .split(' ')[0]
                          : '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text("Organizador: ${conference.creatorName}",
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 16),
          Text(
              "Fecha de la conferencia: ${conference.date.toLocal().toString().split(' ')[0]}",
              style: const TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 20),
          Visibility(
            visible: isVisible,
            child: Center(
              child: ElevatedButton(
                onPressed: () => _enrollUser(ref, context, conference.id),
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

          // Botón de Ver Registrados
          Visibility(
            visible: !isVisible,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConferenceListParticipantsPage(
                          conferenceId: conference.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Ver registrados',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sección de Descripción
          _buildSection("Descripción", conference.description),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _enrollUser(
      WidgetRef ref, BuildContext context, int conferenceId) async {
    final userId = ref.read(authProvider).token?.id;
    if (userId == null) {
      ref.read(snackbarMessageProvider.notifier).state = {
        'message': 'Error: Usuario no autenticado'
      };
      return;
    }

    final registrationData = {'userId': userId, 'conferenceId': conferenceId};
    try {
      await ref.read(createRegistrationProvider(registrationData).future);
      ref.read(snackbarMessageProvider.notifier).state = {
        'message': 'Inscripción exitosa!',
        'shouldPop': true
      };
    } catch (error) {
      ref.read(snackbarMessageProvider.notifier).state = {
        'message': 'Error: $error'
      };
    }
  }

  void _showEditConferenceDialog(
      BuildContext context, WidgetRef ref, Conference conference) {
    final nameController = TextEditingController(text: conference.name);
    final descriptionController =
        TextEditingController(text: conference.description);
    final dateController = TextEditingController(
        text: conference.date.toIso8601String().split('T')[0]);

    // Lista de categorías predefinidas
    final List<String> categories = [
      'Innovación y Tecnología',
      'Investigación y Desarrollo Académico',
      'Empleabilidad y Desarrollo Profesional',
      'Ciencia',
    ];

    // Variable para almacenar la categoría seleccionada
    String? selectedCategory = conference.category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242636),
          title: const Text('Editar Conferencia',
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
                    labelText: 'Nombre de la conferencia',
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
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    labelStyle: TextStyle(color: Colors.white70),
                  ),
                  dropdownColor: const Color(0xFF242636),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedCategory = newValue;
                    }
                  },
                  items:
                      categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha (YYYY-MM-DD)',
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
                _updateConference(
                  ref,
                  conference.id,
                  nameController.text,
                  descriptionController.text,
                  selectedCategory!, // Usar la categoría seleccionada
                  dateController.text,
                );
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

  void _updateConference(WidgetRef ref, int conferenceId, String name,
      String description, String category, String date) {
    final conferenceData = {
      "name": name,
      "description": description,
      "category": category,
      "date": date,
    };

    ref
        .read(conferenceRepositoryProvider)
        .updateConference(conferenceId, conferenceData)
        .then((_) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        const SnackBar(content: Text('Conferencia actualizada exitosamente!')),
      );
      ref.refresh(conferenceByIdProvider(
          conferenceId)); // Refrescar la información de la conferencia
    }).catchError((error) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la conferencia: $error')),
      );
    });
  }
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
