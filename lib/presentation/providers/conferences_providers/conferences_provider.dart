import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/conference/conference_model.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/conference_dto.dart';
import 'package:oev_mobile_app/domain/repositories/conference_repository.dart';
import 'package:oev_mobile_app/presentation/providers/conferences_providers/conference_repository_provider.dart';

final conferenceProvider =
    FutureProvider.autoDispose<List<Conference>>((ref) async {
  final repository = ref.watch(conferenceRepositoryProvider);
  return repository.getConference();
});

final conferenceByIdProvider = FutureProvider.family
    .autoDispose<Conference, int>((ref, conferenceId) async {
  final repository = ref.watch(conferenceRepositoryProvider);
  return repository.getConferenceById(conferenceId);
});

final deleteConferenceProvider =
    FutureProvider.family.autoDispose<void, int>((ref, conferenceId) async {
  final repository = ref.watch(conferenceRepositoryProvider);
  return repository.deleteConferenceById(conferenceId);
});

final addConferenceProvider =
    StateNotifierProvider<AddConferenceNotifier, AsyncValue<Conference>>((ref) {
  final repository = ref.watch(conferenceRepositoryProvider);
  return AddConferenceNotifier(repository);
});

class AddConferenceNotifier extends StateNotifier<AsyncValue<Conference>> {
  final ConferenceRepository repository;

  AddConferenceNotifier(this.repository)
      : super(AsyncData(Conference(
            id: 0,
            name: '',
            description: '',
            imageUrl: '',
            category: '',
            totalStudents: 0,
            status: '',
            creationDate: DateTime.now(),
            lastUpdate: DateTime.now(),
            date: DateTime.now(),
            userId: 0,
            creatorName: '')));

  Future<Conference> addConference(
      int userId, ConferenceRequestDTO conferenceRequestDTO) async {
    state = const AsyncLoading();
    try {
      final conference =
          await repository.addConference(userId, conferenceRequestDTO);
      state = AsyncData(conference);
      return conference;
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
      rethrow;
    }
  }
}
