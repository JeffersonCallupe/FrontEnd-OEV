import 'package:oev_mobile_app/domain/entities/user/user_model.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) =>
      User(id: json['id'], name: json['name'], paternalSurname: json['paternalSurname'], maternalSurname: json['maternalSurname'], email: json['email'], phone: json['phone'], role: json['role']);
}