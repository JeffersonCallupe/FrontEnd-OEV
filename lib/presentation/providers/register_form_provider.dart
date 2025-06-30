import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/user_register_dto.dart';
import 'package:oev_mobile_app/infrastructure/inputs/email.dart';
import 'package:oev_mobile_app/infrastructure/inputs/name.dart';
import 'package:oev_mobile_app/infrastructure/inputs/password.dart';
import 'package:oev_mobile_app/infrastructure/inputs/role.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';

final registerFormProvider = StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((ref) {
  final registerUserCallback = ref.watch(authProvider.notifier).registerUser;

  return RegisterFormNotifier(registerUserCallback: registerUserCallback);
});

//! 2 - Como implementamos un notifier
class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Function(UserRegisterDto) registerUserCallback;

  RegisterFormNotifier({
    required this.registerUserCallback,
  }) : super(RegisterFormState());

  onNameChanged(String value) {
    final newName = Name.dirty(value);
    state = state.copyWith(name: newName, isValid: Formz.validate([newName, state.email, state.role, state.password, state.paternalSurname, state.maternalSurname]));
  }

  onEmailChange(String value) {
    final newEmail = Email.dirty(value);
    state = state.copyWith(email: newEmail, isValid: Formz.validate([newEmail, state.password, state.role, state.name, state.paternalSurname, state.maternalSurname]));
  }

  onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    final isPasswordsMatch = newPassword.value == state.confirmPassword.value;
    state = state.copyWith(
        password: newPassword,
        isPasswordsMatch: isPasswordsMatch,
        isValid: Formz.validate([
          newPassword,
          state.email,
          state.role,
          state.name,
          state.paternalSurname,
          state.maternalSurname,
          state.confirmPassword,
        ]));
  }

  onConfirmPasswordChanged(String value) {
    final newConfirmPassword = Password.dirty(value);
    final isPasswordsMatch = newConfirmPassword.value == state.password.value;
    state = state.copyWith(
        confirmPassword: newConfirmPassword,
        isPasswordsMatch: isPasswordsMatch,
        isValid: Formz.validate([
          newConfirmPassword,
          state.password,
          state.email,
          state.name,
          state.role,
          state.paternalSurname,
          state.maternalSurname,
        ]));
  }

  onRoleChanged(String value) {
    final newRole = Role.dirty(value);
    state = state.copyWith(selectedRole: value, role: newRole, isValid: Formz.validate([newRole, state.email, state.name, state.password, state.paternalSurname, state.maternalSurname]));
  }

  onPaternalSurnameChanged(String value) {
    final newPaternalSurname = Name.dirty(value);
    state = state.copyWith(
        paternalSurname: newPaternalSurname,
        isValid: Formz.validate([
          newPaternalSurname,
          state.email,
          state.name,
          state.password,
          state.role,
          state.maternalSurname,
        ]));
  }

  onMaternalSurnameChanged(String value) {
    final newMaternalSurname = Name.dirty(value);
    state = state.copyWith(
        maternalSurname: newMaternalSurname,
        isValid: Formz.validate([
          newMaternalSurname,
          state.email,
          state.name,
          state.password,
          state.role,
          state.paternalSurname,
        ]));
  }

  onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) return;

    state = state.copyWith(isPosting: true);

    final userRegisterDto = UserRegisterDto(
      name: state.name.value,
      paternalSurname: state.paternalSurname.value,
      maternalSurname: state.maternalSurname.value,
      email: state.email.value,
      password: state.password.value,
      phone: state.phone,
      role: state.role.value.toUpperCase(),
    );

    await registerUserCallback(userRegisterDto);

    state = state.copyWith(isPosting: false);
  }

  _touchEveryField() {
    final name = Name.dirty(state.name.value);
    final paternalSurname = Name.dirty(state.paternalSurname.value);
    final maternalSurname = Name.dirty(state.maternalSurname.value);
    final email = Email.dirty(state.email.value);
    final password = Password.dirty(state.password.value);
    final confirmPassword = Password.dirty(state.confirmPassword.value);
    final role = Role.dirty(state.role.value);

    state = state.copyWith(
      isFormPosted: true,
      name: name,
      paternalSurname: paternalSurname,
      maternalSurname: maternalSurname,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      role: role,
      isValid: Formz.validate([name, paternalSurname, maternalSurname, email, password, confirmPassword, role]),
    );
  }
}

//! 1 - State del provider
class RegisterFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Name name;
  final Name paternalSurname;
  final Name maternalSurname;
  final Email email;
  final Password password;
  final String phone;
  final Role role;
  final String selectedRole;
  final Password confirmPassword;
  final bool isPasswordsMatch; // Asegúrate de agregar este campo en tu estado

  RegisterFormState({
    this.role = const Role.pure(),
    this.name = const Name.pure(),
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.selectedRole = 'student',
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.confirmPassword = const Password.pure(),
    this.isPasswordsMatch = true, // Asegúrate de agregar este campo en tu estado
    this.paternalSurname = const Name.pure(),
    this.maternalSurname = const Name.pure(),
    this.phone = '',
  });

  RegisterFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    String? selectedRole,
    Email? email,
    Password? password,
    Role? role,
    Name? name,
    Name? paternalSurname,
    Name? maternalSurname,
    String? phone,
    Password? confirmPassword,
    bool? isPasswordsMatch,
  }) =>
      RegisterFormState(
        isPosting: isPosting ?? this.isPosting,
        isFormPosted: isFormPosted ?? this.isFormPosted,
        isValid: isValid ?? this.isValid,
        selectedRole: selectedRole ?? this.selectedRole,
        email: email ?? this.email,
        password: password ?? this.password,
        role: role ?? this.role,
        name: name ?? this.name,
        paternalSurname: paternalSurname ?? this.paternalSurname,
        maternalSurname: maternalSurname ?? this.maternalSurname,
        phone: phone ?? this.phone,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        isPasswordsMatch: isPasswordsMatch ?? this.isPasswordsMatch,
      );

  @override
  String toString() {
    return '''
  RegisterFormState:
    isPosting: $isPosting
    isFormPosted: $isFormPosted
    isValid: $isValid
    selectedRole: $selectedRole
    email: $email
    password: $password
    role: $role
    name: $name
    paternalSurname: $paternalSurname
    maternalSurname: $maternalSurname
    phone: $phone
    confirmPassword: $confirmPassword
    isPasswordsMatch: $isPasswordsMatch
''';
  }
}
