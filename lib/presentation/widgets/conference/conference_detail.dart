import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/conference/conference_model.dart';
import 'package:oev_mobile_app/presentation/providers/conferences_providers/conferences_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_providers/registration_provider.dart';

class ConferenceDetailPage extends ConsumerWidget {
  final int conferenceId;

  const ConferenceDetailPage({super.key, required this.conferenceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conferenceAsync = ref.watch(conferenceByIdProvider(conferenceId));

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
    final isVisible = loggedUser?.role == 'STUDENT' || loggedUser?.role == 'ADMINISTRATIVE' || loggedUser?.role == 'INSTRUCTOR';

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

          // Nombre del curso
          Text(
            conference.name,
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

          // Nombre del creador
          Text(
            "Organizador: ${conference.creatorName}",
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 16),

          // Última actualización
          Text(
            "Fecha de la conferencia: ${conference.date.toLocal().toString().split(' ')[0]}",
            // "Fecha de la conferencia: 22 de octubre de 2021",
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),

          const SizedBox(height: 20),

          // Botón de Inscribirse
          Visibility(
            visible: isVisible,
            child: Center(
              child: ElevatedButton(
                onPressed: () =>
                    _showRegistrationConfirmation(context, ref, conference.id),
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
          _buildSection("Descripción", conference.description),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showRegistrationConfirmation(
      BuildContext context, WidgetRef ref, int conferenceId) {
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
          content: const Text('¿Seguro que quieres registrarte en la conferencia?',
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
                Navigator.of(context).pop(); // Cierra el diálogo
                _enrollUser(ref, context, conferenceId);
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

  void _enrollUser(WidgetRef ref, BuildContext context, int conferenceId) {
    final userId = ref.read(authProvider).token?.id;
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado')),
        );
      }
      return;
    }

    final registrationData = {'userId': userId, 'conferenceId': conferenceId};
    ref.read(createRegistrationProvider(registrationData).future).then((_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscripción exitosa!')),
        );
      }
    }).catchError((error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
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
}
