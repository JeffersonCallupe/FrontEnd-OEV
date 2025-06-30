import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/datasources/registration_datasource.dart';
import 'package:oev_mobile_app/domain/entities/dto/conference_registration.dart';
import '../../config/constants/environment.dart';
import '../../domain/errors/auth_errors.dart';
import '../../presentation/providers/auth_provider.dart';

class RegistrationDatasourceImpl implements RegistrationDatasource {
  final _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
    ),
  );

  @override
  Future<void> createRegistration(int userId, int conferenceId) async {
    try {
      final response = await _dio.post('/registration/create', data: {'userId': userId, 'conferenceId': conferenceId});
      if (response.statusCode != 201) {
        throw Exception('Error al inscribirse en la conferencia');
      }
    } catch (e) {
      throw Exception('Error en la petición: $e');
    }
  }

  @override
  Future<void> deleteRegistration(int registrationId) async {
    try {
      final response = await _dio.delete('/registration/delete/$registrationId');
      if (response.statusCode != 204) {
        throw Exception('Error al eliminar la inscripción');
      }
    } catch (e) {
      throw Exception('Error en la petición: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> findRegisteredUsersByConferenceId(int conferenceId) async {
    try {
      final response = await _dio.get('/registration/findRegisteredUsersByConferenceId/$conferenceId');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Error al obtener los usuarios inscritos');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw WrongCredentials();
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeout();
      }
      throw CustomError('Something wrong happened');
    } catch (e) {
      throw CustomError('Something wrong happened');
    }
  }

  @override
  Future<List<ConferenceRegistration>> getRegistrationsByUserId(int userId) {
    try {
      return _dio.get('/registration/findAllByUserId/$userId').then(
        (response) {
          if (response.statusCode == 200) {
            return List<ConferenceRegistration>.from(
              response.data.map(
                (registration) => ConferenceRegistration.fromJson(registration),
              ),
            );
          } else {
            throw Exception('Error al obtener las inscripciones');
          }
        },
      );
    } catch (e) {
      throw Exception('Error en la petición: $e');
    }
  }
}
