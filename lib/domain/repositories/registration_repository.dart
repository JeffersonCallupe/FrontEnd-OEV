abstract class RegistrationRepository {
  Future<void> createRegistration(int userId, int conferenceId);
  Future<void> deleteRegistration(int registrationId);
}