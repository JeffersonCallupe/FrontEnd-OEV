import 'package:dio/dio.dart';
import 'package:oev_mobile_app/domain/datasources/lesson_datasource.dart';
import 'package:oev_mobile_app/domain/entities/lesson/lesson_model.dart';
import '../../config/constants/environment.dart';
import '../../domain/errors/auth_errors.dart';

class LessonDatasourceImpl implements LessonDataSource {
  final _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
    ),
  );

  @override
  Future<List<Lesson>> getLessonsByCourseId(int courseId) async {
    try {
      final response = await _dio.get('/lesson/findLessonsByCourseId/$courseId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Lesson.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar las lecciones');
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
  Future<Lesson> createLesson(int courseId, String title, String videoKey) async {
    try {
      final response = await _dio.post(
        '/lesson/create/$courseId',
        data: {
          "title": title,
          "videoKey": videoKey,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Lesson.fromJson(response.data);
      } else {
        throw Exception('Error al crear la lección');
      }
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

  @override
  Future<void> deleteLessonById(int lessonId) {
    try {
      return _dio.delete('/lesson/delete/$lessonId');
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