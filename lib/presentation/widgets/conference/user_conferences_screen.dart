import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/conferences_providers/conferences_provider.dart';
import 'package:oev_mobile_app/presentation/widgets/conference/conference_card.dart';

class UserConferencesScreen extends ConsumerWidget {
  const UserConferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedUser = ref.read(authProvider).token;
    final asyncConferences = ref.watch(conferenceProvider);

    return Scaffold(
      backgroundColor: const Color(0xff343646),
      appBar: AppBar(
        backgroundColor: const Color(0xff343646),
        title: const Text(
          'Mis Conferencias',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: asyncConferences.when(
        data: (conferences) {
          final userConferences = conferences
              .where((conference) => conference.userId == loggedUser!.id)
              .toList();

          if (userConferences.isEmpty) {
            return const Center(
              child: Text(
                'No has creado ninguna conferencia aún.',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 4 / 4.4,
              ),
              itemCount: userConferences.length,
              itemBuilder: (context, index) {
                return ConferenceCard(conference: userConferences[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
