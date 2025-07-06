import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/user_register_dto.dart';
import 'package:oev_mobile_app/domain/entities/token/token_model.dart';
import 'package:oev_mobile_app/domain/errors/auth_errors.dart';
import 'package:oev_mobile_app/domain/repositories/auth_repository.dart';
import 'package:oev_mobile_app/infrastructure/repositories/auth_repository_impl.dart';
import 'package:oev_mobile_app/infrastructure/shared/services/key_value_storage_service.dart';
import 'package:oev_mobile_app/infrastructure/shared/services/key_value_storage_service_impl.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();
  final keyValueStorageService = KeyValueStorageServiceImpl();
  return AuthNotifier(
    authRepository: authRepository,
    keyValueStorageService: keyValueStorageService,
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;

  AuthNotifier({
    required this.keyValueStorageService,
    required this.authRepository,
  }) : super(AuthState()) {
    checkAuthStatus();
  }

  Future<void> loginUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      state = state.copyWith(isLoading: true);
      final token = await authRepository.login(email, password);
      print('token loginUser: $token');
      _setLoggedUser(token);
    } on WrongCredentials {
      logout('Credenciales no son correctas');
    } on ConnectionTimeout {
      logout('Timeout de conexión');
    } catch (e) {
      logout('Error desconocido');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> registerUser(UserRegisterDto userRegisterDto) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await authRepository.register(userRegisterDto);
      print('User: $user');
    } on WrongCredentials {
      // Manejar error de credenciales incorrectas
    } on ConnectionTimeout {
      // Manejar error de tiempo de conexión
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<Token>('token');
    if (token == null) return logout();

    try {
      final token1 = await authRepository.checkAuthStatus(token);
      _setLoggedUser(token1);
    } catch (e) {
      logout();
    }
  }

  Future<void> _setLoggedUser(Token token) async {
    try {
      await keyValueStorageService.setKeyValue('token', token);
      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
        token: token,
        errorMessage: '',
      );
    } catch (e) {
      print('Error setting logged user: $e');
      logout('Error al guardar la sesión');
    }
  }

  // New method to update token after profile update
  Future<void> updateToken(Token updatedToken) async {
    try {
      await keyValueStorageService.setKeyValue('token', updatedToken);
      state = state.copyWith(
        token: updatedToken,
        errorMessage: '',
      );
    } catch (e) {
      print('Error updating token: $e');
      state = state.copyWith(
        errorMessage: 'Error actualizando datos locales',
      );
    }
  }

  // Updated logout method to handle both normal logout and error cases
  Future<void> logout([String? errorMessage]) async {
    try {
      await keyValueStorageService.removeKey('token');
    } catch (e) {
      print('Error removing token: $e');
    } finally {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        token: null,
        errorMessage: errorMessage,
      );
    }
  }

  Future<String> getValidToken() async {
    final currentToken = state.token;
    if (currentToken == null) {
      throw NotAuthorizedException('No hay sesión activa');
    }

    // Verificar si el token está próximo a expirar (5 minutos antes)
    final exp = _getTokenExpiration(currentToken.token);
    if (exp != null &&
        DateTime.now().isAfter(exp.subtract(const Duration(minutes: 5)))) {
      // Intentar renovar el token
      try {
        final newToken = await authRepository.checkAuthStatus(currentToken);
        await updateToken(newToken);
        return newToken.token;
      } catch (e) {
        await logout('Sesión expirada');
        throw NotAuthorizedException('Sesión expirada');
      }
    }

    return currentToken.token;
  }

  DateTime? _getTokenExpiration(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      return DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
    } catch (e) {
      print('Error decodificando token: $e');
      return null;
    }
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final Token? token;
  final String errorMessage;
  final bool isLoading;

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.token,
    this.errorMessage = '',
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    Token? token,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}