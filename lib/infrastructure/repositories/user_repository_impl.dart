import 'package:oev_mobile_app/domain/datasources/user_datasource.dart';
import 'package:oev_mobile_app/domain/entities/user/user_model.dart';
import 'package:oev_mobile_app/domain/repositories/user_repository.dart';
import 'package:oev_mobile_app/infrastructure/datasources/user_datasource_impl.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;

  UserRepositoryImpl({UserDataSource? dataSource})
      : dataSource = dataSource ?? UserDataSourceImpl();

  @override
  Future<User> updateUser(int id, Map<String, dynamic> userData, String token) {
    return dataSource.updateUser(id, userData, token);
  }
}