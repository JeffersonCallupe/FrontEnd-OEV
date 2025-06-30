import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/config/constants/environment.dart';
import 'package:oev_mobile_app/domain/datasources/registration_datasource.dart';

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
      final response = await _dio.post('/registration/create',
          data: {'userId': userId, 'conferenceId': conferenceId});
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
}
