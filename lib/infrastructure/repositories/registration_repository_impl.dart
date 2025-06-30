import 'package:oev_mobile_app/domain/datasources/registration_datasource.dart';
import 'package:oev_mobile_app/domain/entities/dto/conference_registration.dart';
import 'package:oev_mobile_app/domain/repositories/registration_repository.dart';
import 'package:oev_mobile_app/infrastructure/datasources/registration_datasources_impl.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationDatasource dataSource;

  RegistrationRepositoryImpl({required this.dataSource});

  @override
  Future<void> createRegistration(int userId, int conferenceId) {
    return dataSource.createRegistration(userId, conferenceId);
  }

  @override
  Future<void> deleteRegistration(int registrationId) {
    return dataSource.deleteRegistration(registrationId);
  }

  @override
  Future<List<Map<String, dynamic>>> findRegisteredUsersByConferenceId(int conferenceId) {
    return dataSource.findRegisteredUsersByConferenceId(conferenceId);
  }

  @override
  Future<List<ConferenceRegistration>> getRegistrationsByUserId(int userId) {
    return dataSource.getRegistrationsByUserId(userId);
  }
}
