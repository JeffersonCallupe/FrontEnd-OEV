import 'package:oev_mobile_app/domain/entities/user/user_model.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) {
    try {
      // Validar que todos los campos requeridos estén presentes
      if (json['id'] == null) {
        throw Exception('ID no encontrado en la respuesta');
      }
      
      // Convertir el ID a int de forma segura
      final id = json['id'] is int ? json['id'] : int.parse(json['id'].toString());
      
      return User(
        id: id,
        name: json['name']?.toString() ?? '',
        paternalSurname: json['paternalSurname']?.toString() ?? '',
        maternalSurname: json['maternalSurname']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        role: json['role']?.toString() ?? '',
      );
    } catch (e) {
      print('Error en UserMapper: $e');
      print('JSON recibido: $json');
      throw Exception('Error al mapear usuario: $e');
    }
  }
}