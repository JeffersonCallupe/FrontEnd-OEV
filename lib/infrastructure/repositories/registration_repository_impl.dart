import 'package:oev_mobile_app/domain/datasources/registration_datasource.dart';
import 'package:oev_mobile_app/domain/repositories/registration_repository.dart';
import 'package:oev_mobile_app/infrastructure/datasources/registration_datasources_impl.dart';

class RegistrationRepositoryImpl implements RegistrationRepository {
  final RegistrationDatasource registrationDatasource;

  RegistrationRepositoryImpl({RegistrationDatasource? registrationDatasource, required RegistrationDatasource dataSource})
      : registrationDatasource =
      registrationDatasource ?? RegistrationDatasourceImpl();

  @override
  Future<void> createRegistration(int userId, int conferenceId) {
    return registrationDatasource.createRegistration(userId, conferenceId);
  }

  @override
  Future<void> deleteRegistration(int registrationId) {
    return registrationDatasource.deleteRegistration(registrationId);
  }
}
