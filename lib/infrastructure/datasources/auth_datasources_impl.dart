import 'package:dio/dio.dart';
import 'package:oev_mobile_app/config/constants/environment.dart';
import 'package:oev_mobile_app/domain/datasources/auth_datasource.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/user_register_dto.dart';
import 'package:oev_mobile_app/domain/entities/token/token_model.dart';
import 'package:oev_mobile_app/domain/entities/user/user_model.dart';
import 'package:oev_mobile_app/domain/errors/auth_errors.dart';
import 'package:oev_mobile_app/infrastructure/mappers/token_mapper.dart';
import 'package:oev_mobile_app/infrastructure/mappers/user_mapper.dart';

class AuthDataSourceImpl implements AuthDataSource {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
    ),
  );
  @override
  Future<Token> checkAuthStatus(Token token) async {
    return Token(
      id: token.id,
      name: token.name,
      paternalSurname: token.paternalSurname,
      maternalSurname: token.maternalSurname,
      email: token.email,
      phone: token.phone,
      role: token.role,
      token: token.token,
    );
  }

  @override
  Future<Token> login(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      final token = TokenMapper.userJsonToEntity(response.data);

      return token;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw WrongCredentials();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw ConnectionTimeout();
      }
      throw CustomError('Something wrong happend');
    } catch (e) {
      throw CustomError('Something wrong happend');
    }
  }

  @override
  Future<User> register(UserRegisterDto userRegisterDto) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: UserRegisterDto.entityToJson(userRegisterDto),
      );
      print("userinfo: ${response.data}");
      final user = UserMapper.userJsonToEntity(response.data);
      print("user: $user");
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw WrongCredentials();
      }
      if (e.type == DioExceptionType.connectionError) {
        throw ConnectionTimeout();
      }
      throw CustomError('Something wrong happend');
    } catch (e) {
      throw CustomError('Something wrong happend');
    }
  }
}
