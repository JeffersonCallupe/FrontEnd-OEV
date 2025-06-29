import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:oev_mobile_app/config/constants/environment.dart';

// Modelo para la respuesta del backend
class PresignedUrlDTO {
  final String url;

  PresignedUrlDTO({required this.url});

  factory PresignedUrlDTO.fromJson(Map<String, dynamic> json) {
    return PresignedUrlDTO(url: json['url']);
  }
}

final _dio = Dio(
  BaseOptions(
    baseUrl: Environment.apiUrl,
  ),
);
final _bucketName = Environment.bucketName;

// Provider para obtener la URL firmada
final presignedUrlProvider =
    FutureProvider.family<String, String>((ref, lessonVideoKey) async {
  final response = await _dio.get(
    "/s3/file/download-url",
    queryParameters: {
      "bucketName": _bucketName,
      "key": lessonVideoKey,
      "durationSeconds": 3600 // 1 hora de validez
    },
  );

  if (response.statusCode == 200) {
    return PresignedUrlDTO.fromJson(response.data).url;
  } else {
    throw Exception("Error obteniendo la URL del video");
  }
});
