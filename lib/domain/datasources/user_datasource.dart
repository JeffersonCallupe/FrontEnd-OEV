import 'package:oev_mobile_app/domain/entities/user/user_model.dart';

abstract class UserDataSource {
  Future<User> updateUser(int id, Map<String, dynamic> userData, String token);
}