import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      final token = await authRepository.login(email, password);
      print('token loginUser: $token');
      _setLoggedUser(token);
    } on WrongCredentials {
      logout('Credenciales no son correctas');
    } on ConnectionTimeout {
      logout('Timeout de conexión');
    } catch (e) {
      logout('Error desconocido');
    }
  }

  Future<void> registerUser(String email, String password, String name, String rol, String lastName) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await authRepository.register(email, password, name, rol, lastName);
      print('User: $user');
    } on WrongCredentials {
      // Manejar error de credenciales incorrectas
    } on ConnectionTimeout {
      // Manejar error de tiempo de conexión
    } catch (e) {
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void checkAuthStatus() async {
    final token = await keyValueStorageService.getValue<String>('token');
    if (token == null) return logout();

    try {
      final token1 = await authRepository.checkAuthStatus('token');
      _setLoggedUser(token1);
    } catch (e) {
      logout();
    }
  }

  void _setLoggedUser(Token token) async {
    await keyValueStorageService.setKeyValue('token', token.token);
    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      token: token,
      errorMessage: '',
    );
  }

  Future<void> logout([String? errorMessage]) async {
    await keyValueStorageService.removeKey('token');

    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      token: null,
      errorMessage: errorMessage,
    );
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final Token? token;
  final String errorMessage;
  final bool isLoading;
  // Nueva variable para el estado de registro

  AuthState({
    this.authStatus = AuthStatus.checking,
    this.token,
    this.errorMessage = '',
    this.isLoading = false,
    // Valor inicial de isRegistered
  });

  AuthState copyWith({
    AuthStatus? authStatus,
    Token? token,
    String? errorMessage,
    bool? isLoading,
    // Añadir isRegistered a copyWith
  }) {
    return AuthState(
      authStatus: authStatus ?? this.authStatus,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      // Copiar isRegistered
    );
  }
}
