import 'package:oev_mobile_app/domain/entities/token/token_model.dart';
import 'package:oev_mobile_app/domain/entities/user/user_model.dart';

abstract class AuthDataSource {
  Future<Token> login(String email, String password);
  Future<User> register(String email, String password, String name, String rol, String lastName);
  Future<Token> checkAuthStatus(String token);
}
