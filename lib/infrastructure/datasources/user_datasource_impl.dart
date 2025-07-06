import 'package:dio/dio.dart';
import 'package:oev_mobile_app/config/constants/environment.dart';
import 'package:oev_mobile_app/domain/datasources/user_datasource.dart';
import 'package:oev_mobile_app/domain/entities/user/user_model.dart';
import 'package:oev_mobile_app/domain/errors/auth_errors.dart';
import 'package:oev_mobile_app/infrastructure/mappers/user_mapper.dart'; 

class UserDataSourceImpl implements UserDataSource {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  Future<User> updateUser(
      int id, Map<String, dynamic> userData, String token) async {
    try {
      // Aseguramos que el ID sea enviado como un número
      final numericId = id.toInt();
      print('Updating user with ID: $numericId');
      
      // NO incluimos el ID en el cuerpo del request, solo en la URL
      final Map<String, dynamic> formattedData = {
        'name': userData['name'] as String,
        'paternalSurname': userData['paternalSurname'] as String,
        'maternalSurname': userData['maternalSurname'] as String,
        'email': userData['email'] as String,
        'phone': userData['phone'] as String,
      };
      
      print('Update data: $formattedData');
      print('Using token: $token');
      
      final bearerToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      print('Using bearerToken: $bearerToken');
      
      // Corregir la URL para que coincida con el controlador
      final response = await dio.patch(
        '/api/user/updateUser/$numericId',  // ✅ URL corregida
        data: formattedData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': bearerToken,
          },
          validateStatus: (status) {
            return status != null && status < 500;
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw NotAuthorizedException('Sesión expirada o inválida');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Verificar si la respuesta es válida antes de mapear
        if (response.data != null && response.data is Map<String, dynamic>) {
          return UserMapper.userJsonToEntity(response.data);
        } else {
          throw Exception('Respuesta del servidor inválida');
        }
      } else {
        final errorMessage = response.data?['message'] ??
            'Error desconocido en la actualización';
        throw Exception('Error del servidor: $errorMessage');
      }
    } on DioException catch (e) {
      print('DioError: ${e.type}');
      print('DioError message: ${e.message}');
      print('DioError response: ${e.response?.data}');

      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        throw Exception('No autorizado. Por favor, vuelve a iniciar sesión.');
      }

      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      print('Error inesperado: $e');
      throw Exception('Error inesperado: $e');
    }
  }
} 