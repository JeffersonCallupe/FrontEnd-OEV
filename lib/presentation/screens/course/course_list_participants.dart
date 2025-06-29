import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/enrollment_providers/enrollment_provider.dart';

class CourseListParticipantsPage extends ConsumerWidget {
  final int courseId;

  const CourseListParticipantsPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrolledUsersAsync = ref.watch(enrolledUsersProvider(courseId));

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
                "No hay inscritos en este curso",
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
                          user['name'] + ' ' + user['paternalSurname'],
                          style: const TextStyle(color: Colors.white))),
                      DataCell(Text(user['email'],
                          style: const TextStyle(color: Colors.white))),
                      DataCell(Text(user['phone'],
                          style: const TextStyle(color: Colors.white))),
                      DataCell(Text(
                          user['role'] == 'STUDENT'
                              ? 'Estudiante'
                              : 'Administrativo',
                          style: const TextStyle(color: Colors.white))),
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
}
