abstract class RegistrationDatasource {
  Future<void> createRegistration(int userId, int conferenceId);
  Future<void> deleteRegistration(int registrationId);
}