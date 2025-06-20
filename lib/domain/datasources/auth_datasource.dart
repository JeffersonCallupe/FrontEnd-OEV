import 'package:oev_mobile_app/domain/entities/dto/request/user_register_dto.dart';
import 'package:oev_mobile_app/domain/entities/token/token_model.dart';
import 'package:oev_mobile_app/domain/entities/user/user_model.dart';

abstract class AuthDataSource {
  Future<Token> login(String email, String password);
  Future<User> register(UserRegisterDto userRegisterDto);
  Future<Token> checkAuthStatus(Token token);
}