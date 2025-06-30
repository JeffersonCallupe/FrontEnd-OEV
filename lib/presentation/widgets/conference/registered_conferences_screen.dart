import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/registration_providers/registration_provider.dart';

class RegisteredConferencesScreen extends ConsumerWidget {
  const RegisteredConferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedUser = ref.watch(authProvider).token;

    final asyncConferencesRegistration = ref.watch(registrationsByUserIdProvider(loggedUser!.id));

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        title: const Text(
          'Lista de Conferencias Inscritas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: asyncConferencesRegistration.when(
        data: (conferences) {
          if (conferences.isEmpty) {
            return const Center(
              child: Text(
                'No estás inscrito en ninguna conferencia.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
            itemCount: conferences.length,
            itemBuilder: (context, index) {
              final conference = conferences[index];
              return Card(
                color: const Color(0xFF242636),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    conference.conferenceName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Fecha: ${conference.conferenceDate}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: const Icon(Icons.event, color: Colors.blue),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text(
            'Error al cargar conferencias',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
