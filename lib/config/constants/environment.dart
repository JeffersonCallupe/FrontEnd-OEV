import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: ".env");
  }

  static String apiUrl =
      dotenv.env['API_URL'] ?? 'No esta configurado el API_URL';
  static String bucketName =
      dotenv.env['BUCKET_NAME'] ?? 'No esta configurado el BUCKET_NAME';

  static String videoFolder = dotenv.env['VIDEO_FOLDER'] ?? 'No esta configurado el VIDEO_FOLDER';
}
