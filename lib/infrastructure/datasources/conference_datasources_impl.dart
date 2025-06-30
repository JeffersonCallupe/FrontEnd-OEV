import 'package:dio/dio.dart';
import 'package:oev_mobile_app/config/constants/environment.dart';
import 'package:oev_mobile_app/domain/datasources/conference_datasource.dart';
import 'package:oev_mobile_app/domain/entities/conference/conference_model.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/conference_dto.dart';
import 'package:oev_mobile_app/infrastructure/mappers/conference_mapper.dart';

class ConferenceDatasourceImpl implements ConferenceDatasource {
  final _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
    ),
  );

  @override
  Future<List<Conference>> getConference() async {
    try {
      final response = await _dio.get('/conference/findAll');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ConferenceMapper.userJsonToEntity(json)).toList();
      } else {
        throw Exception('Error al cargar los cursos');
      }
    } catch (e) {
      throw Exception('Error en la petición: $e');
    }
  }

  @override
  Future<Conference> getConferenceById(int conferenceId) async {
    try {
      final response = await _dio.get('/conference/findConference/$conferenceId');
      if (response.statusCode == 200) {
        return ConferenceMapper.userJsonToEntity(response.data);
      } else {
        throw Exception('Error al obtener el curso con ID $conferenceId');
      }
    } catch (e) {
      throw Exception('Error en la petición: $e');
    }
  }

  @override
  Future<void> deleteConferenceById(int conferenceId) async {
    try {
      final response = await _dio.delete('/conference/delete/$conferenceId');
      if (response.statusCode != 204) {
        throw Exception('Error al eliminar la conferencia');
      }
    } catch (e) {
      throw Exception('Error en la petición: $e');
    }
    return Future.value();
  }

  @override
  Future<Conference> addConference(int userId, ConferenceRequestDTO conferenceRequestDTO) async {
    try {
      final response = await _dio.post(
        '/conference/create/$userId',
        data: conferenceRequestDTO.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return ConferenceMapper.userJsonToEntity(response.data);
      } else {
        throw Exception('Error al agregar el curso');
      }
    } catch (e) {
      throw Exception('Error en la petición: $e');
    }
  }
}