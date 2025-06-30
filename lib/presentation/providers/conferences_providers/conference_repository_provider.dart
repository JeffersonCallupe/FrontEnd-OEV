import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/repositories/conference_repository.dart';
import 'package:oev_mobile_app/infrastructure/repositories/conference_repository_impl.dart';

final conferenceRepositoryProvider = Provider<ConferenceRepository>((ref) {
  return ConferenceRepositoryImpl();
});
