import 'package:oev_mobile_app/domain/entities/token/token_model.dart';

class TokenMapper {
  static Token userJsonToEntity(Map<String, dynamic> json) => Token(
        token: json['token'],
      );
}
