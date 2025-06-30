import 'package:oev_mobile_app/domain/entities/dto/conference_registration.dart';

abstract class RegistrationDatasource {
  Future<void> createRegistration(int userId, int conferenceId);
  Future<void> deleteRegistration(int registrationId);
  Future<List<Map<String, dynamic>>> findRegisteredUsersByConferenceId(int conferenceId);

  Future<List<ConferenceRegistration>> getRegistrationsByUserId(int userId);
}
