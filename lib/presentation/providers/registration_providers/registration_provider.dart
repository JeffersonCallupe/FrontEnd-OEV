import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/repositories/registration_repository.dart';
import 'package:oev_mobile_app/domain/datasources/registration_datasource.dart';
import 'package:oev_mobile_app/infrastructure/datasources/registration_datasources_impl.dart';
import 'package:oev_mobile_app/infrastructure/repositories/registration_repository_impl.dart';

// Datasource Provider
final registrationDatasourceProvider = Provider<RegistrationDatasource>((ref) {
  return RegistrationDatasourceImpl();
});

// Repository Provider
final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  final datasource = ref.read(registrationDatasourceProvider);
  return RegistrationRepositoryImpl(dataSource: datasource);
});

// Create Registration Provider
final createRegistrationProvider = FutureProvider.family.autoDispose<void, Map<String, int>>((ref, data) async {
  final repository = ref.watch(registrationRepositoryProvider);
  await repository.createRegistration(data['userId']!, data['conferenceId']!);
});

// Delete Registration Provider
final deleteRegistrationProvider = FutureProvider.family.autoDispose<void, int>((ref, registrationId) async {
  final repository = ref.watch(registrationRepositoryProvider);
  await repository.deleteRegistration(registrationId);
});