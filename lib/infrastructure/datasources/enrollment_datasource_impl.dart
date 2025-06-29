import 'package:dio/dio.dart';
import 'package:oev_mobile_app/domain/datasources/enrollment_datasource.dart';
import '../../config/constants/environment.dart';
import '../../domain/errors/auth_errors.dart';

class EnrollmentDatasourceImpl implements EnrollmentDatasource {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
    ),
  );

  @override
  Future<bool> enrollUserInCourse(int userId, int courseId) async {
    try {
      final response = await dio.post(
        '/enrollment/create',
        data: {
          'userId': userId,
          'courseId': courseId,
        },
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
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
  Future<List<Map<String, dynamic>>> findEnrolledUsersByCourseId(
      int courseId) async {
    try {
      final response =
          await dio.get('/enrollment/findEnrolledUsersByCourseId/$courseId');
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
  Future<void> deleteEnrollmentById(int enrollmentId) {
    try {
      return dio.delete('/enrollment/delete/$enrollmentId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw WrongCredentials();
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ConnectionTimeout();
      }
      throw CustomError('Something went wrong');
    } catch (e) {
      throw CustomError('Something went wrong');
    }
  }
}