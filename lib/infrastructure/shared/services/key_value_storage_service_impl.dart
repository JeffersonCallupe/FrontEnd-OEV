import 'dart:convert';
import 'package:oev_mobile_app/domain/entities/token/token_model.dart';
import 'package:oev_mobile_app/infrastructure/mappers/token_mapper.dart';
import 'package:oev_mobile_app/infrastructure/shared/services/key_value_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KeyValueStorageServiceImpl extends KeyValueStorageService {
  Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  @override
  Future<T?> getValue<T>(String key) async {
    final prefs = await getSharedPrefs();

    switch (T) {
      case int:
        return prefs.getInt(key) as T?;

      case String:
        return prefs.getString(key) as T?;

      case bool:
        return prefs.getBool(key) as T?;

      case double:
        return prefs.getDouble(key) as T?;

      case Token:
        final jsonString = prefs.getString(key);
        if (jsonString != null) {
          return TokenMapper.userJsonToEntity(json.decode(jsonString)) as T?;
        }
        return null;

      default:
      throw UnimplementedError('GET not implemented for type $T');
    }
  }

  @override
  Future<bool> removeKey(String key) async {
    final prefs = await getSharedPrefs();
    return await prefs.remove(key);
  }

  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    final prefs = await getSharedPrefs();

    switch (T) {
      case int:
        prefs.setInt(key, value as int);
        break;

      case String:
        prefs.setString(key, value as String);
        break;

      case bool:
        prefs.setBool(key, value as bool);
        break;

      case double:
        prefs.setDouble(key, value as double);
        break;

      case Token:
        final jsonString = json.encode(TokenMapper.entityToJson(value as Token));
        await prefs.setString(key, jsonString);
        break;

      default:
        throw UnimplementedError('Set not implemented for type $T');
    }
  }
}