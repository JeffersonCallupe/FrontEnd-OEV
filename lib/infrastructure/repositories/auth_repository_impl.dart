import 'package:oev_mobile_app/domain/datasources/auth_datasource.dart';
import 'package:oev_mobile_app/domain/entities/token/token_model.dart';
import 'package:oev_mobile_app/domain/entities/user/user_model.dart';
import 'package:oev_mobile_app/domain/repositories/auth_repository.dart';
import 'package:oev_mobile_app/infrastructure/datasources/auth_datasources_impl.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({AuthDataSource? dataSource}) : dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<Token> checkAuthStatus(String token) {
    return dataSource.checkAuthStatus(token);
  }

  @override
  Future<Token> login(String email, String password) {
    return dataSource.login(email, password);
  }

  @override
  Future<User> register(String email, String password, String name, String rol, String lastName) {
    return dataSource.register(email, password, name, rol, lastName);
  }
}
