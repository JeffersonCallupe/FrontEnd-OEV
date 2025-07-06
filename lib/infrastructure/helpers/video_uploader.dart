import 'dart:io';
import 'package:logging/logging.dart';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oev_mobile_app/config/constants/environment.dart';
import 'package:oev_mobile_app/domain/repositories/lesson_repository.dart';
import 'package:oev_mobile_app/infrastructure/repositories/lesson_repository_impl.dart';
import 'package:oev_mobile_app/domain/entities/lesson/lesson_model.dart';


class VideoUploader {
  final _logger = Logger('VideoUploader');
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
    ),
  );
  final String backendUrl = '/s3/file/upload-url';
  final String bucketName = Environment.bucketName;
  final LessonRepository lessonRepository = LessonRepositoryImpl();

  /// Permite al usuario seleccionar un video desde la galería
  Future<File?> pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  /// Obtiene la URL firmada para subir el video
  Future<String?> getPresignedUrl(String fileName) async {
    try {
      final response = await _dio.get(
        backendUrl,
        queryParameters: {
          'bucketName': bucketName,
          'key': fileName,
          'durationSeconds': 300, // Expira en 5 minutos
        },
      );

      if (response.statusCode == 200) {
        return response.data['url'];
      }
    } catch (e) {
      _logger.severe("Error al obtener la URL firmada: $e");
    }
    return null;
  }

  Future<bool> uploadVideoToS3(File videoFile, String presignedUrl) async {
    try {
      _logger.info("Iniciando subida del video...");

      var fileStream = videoFile.openRead();
      var length = await videoFile.length();

      final response = await _dio.put(
        presignedUrl,
        data: fileStream,
        options: Options(
          headers: {
            "Content-Type": "video/mp4",
            "Content-Length": length.toString(),
          },
        ),
      );

      if (response.statusCode == 200) {
        _logger.info("Video subido correctamente!");
        return true;
      }
    } catch (e) {
      _logger.severe("Excepción al subir el video: $e");
    }
    return false;
  }

  /// Selecciona, sube video y crea la lección
  Future<void> uploadLessonVideo(int courseId, String lessonTitle, File? videoFile) async {

    if (videoFile == null) {
      _logger.warning("No se seleccionó ningún video.");
      return;
    }

    String lessonVideoFolder = Environment.videoFolder;
    String fileName = '$lessonVideoFolder/${courseId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
    String? presignedUrl = await getPresignedUrl(fileName);

    if (presignedUrl == null) {
      _logger.severe("No se pudo obtener la URL firmada.");
      return;
    }

    bool success = await uploadVideoToS3(videoFile, presignedUrl);
    if (!success) {
      _logger.severe("Hubo un problema en la subida.");
      return;
    }

    try {
      Lesson newLesson = await lessonRepository.createLesson(courseId, lessonTitle, fileName);
      _logger.info("Lección creada: ${newLesson.title}");
    } catch (e) {
      _logger.severe("Error al crear la lección: $e");
    }
  }
}
