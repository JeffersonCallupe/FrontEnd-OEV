import 'package:formz/formz.dart';

// Define input validation errors
enum RoleError { empty, invalid }

// Extend FormzInput and provide the input type and error type.
class Role extends FormzInput<String, RoleError> {
  // Call super.pure to represent an unmodified form input.
  const Role.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const Role.dirty(super.value) : super.dirty();

  String? get errorMessage {
    if (isValid || isPure) return null;

    switch (displayError) {
      case RoleError.empty:
        return 'El campo de rol no puede estar vacío.';
      case RoleError.invalid:
        return 'El rol debe ser "student" o "instructor o "administrative".';
      default:
        return null;
    }
  }

  // Validador actualizado para verificar si el valor es "student" o "instructor" o administrative.
  @override
  RoleError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) {
      return RoleError.empty;
    }
    if (value != "student" && value != "instructor" && value != "administrative") {
      return RoleError.invalid;
    }

    return null; // null significa que no hay error
  }
}