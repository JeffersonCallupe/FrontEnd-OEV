import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/registration_providers/registration_provider.dart';

class ConferenceListParticipantsPage extends ConsumerWidget {
  final int conferenceId;

  const ConferenceListParticipantsPage({super.key, required this.conferenceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledUsersAsync = ref.watch(registeredUsersProvider(conferenceId));

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Lista de Inscritos',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: enrolledUsersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(
              child: Text(
                "No hay inscritos en esta conferencia",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal, // Permite desplazamiento lateral
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                    (states) => const Color(0xFF2A2A3A)), // Fondo del header
                dataRowColor: MaterialStateColor.resolveWith(
                    (states) => const Color(0xFF2A2A3A)), // Fondo filas
                columnSpacing: 25, // Espaciado entre columnas
                headingTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
                columns: const [
                  DataColumn(
                      label: Text('Nombre',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Correo',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Teléfono',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label:
                          Text('Rol', style: TextStyle(color: Colors.white))),
                ],
                rows: users.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(
                        "${user['name'] ?? 'Desconocido'} ${user['paternalSurname'] ?? ''}"
                            .trim(),
                        style: const TextStyle(color: Colors.white),
                      )),
                      DataCell(Text(
                        user['email'] ?? 'No disponible',
                        style: const TextStyle(color: Colors.white),
                      )),
                      DataCell(Text(
                        user['phone'] ?? 'No disponible',
                        style: const TextStyle(color: Colors.white),
                      )),
                      DataCell(Text(
                        _getRoleName(user['role']),
                        style: const TextStyle(color: Colors.white),
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (error, _) => Center(
          child: Text(
            "Error: $error",
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }

  String _getRoleName(String? role) {
    switch (role) {
      case 'STUDENT':
        return 'Estudiante';
      case 'INSTRUCTOR':
        return 'Instructor';
      case 'ADMINISTRATIVE':
        return 'Administrativo';
      default:
        return 'Desconocido';
    }
  }
}
