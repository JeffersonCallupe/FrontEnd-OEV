import 'package:oev_mobile_app/domain/entities/token/token_model.dart';

class TokenMapper {
  static Token userJsonToEntity(Map<String, dynamic> json) => Token(
        id: json['id'],
        name: json['name'],
        paternalSurname: json['paternalSurname'],
        maternalSurname: json['maternalSurname'],
        email: json['email'],
        phone: json['phone'],
        role: json['role'],
        token: json['token'],
      );

  static Map<String, dynamic> entityToJson(Token token) => {
        'id': token.id,
        'name': token.name,
        'paternalSurname': token.paternalSurname,
        'maternalSurname': token.maternalSurname,
        'email': token.email,
        'phone': token.phone,
        'role': token.role,
        'token': token.token,
      };
}