import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/register_form_provider.dart';

class RegisterScreen extends StatefulWidget {
  static const String name = 'register_screen';
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color.fromARGB(255, 30, 30, 44),
      body: _RegisterForm(),
    );
  }
}

class _RegisterForm extends ConsumerWidget {
  const _RegisterForm();

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);
    final authState = ref.watch(authProvider);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50.0),
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                'assets/images/oev_logo.png',
                width: 240,
                height: 100,
              ),
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Registro',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Open Sans',
                  fontSize: 36.0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Seleccione su rol',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'PT Sans',
                  fontSize: 14.0,
                ),
              ),
            ),
            const SizedBox(height: 15),
            InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                contentPadding: const EdgeInsets.all(10),
                errorText: ref.read(registerFormProvider).role.errorMessage,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Colors.grey[800],
                  value: ref.watch(registerFormProvider).selectedRole,
                  elevation: 16,
                  style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255)),
                  onChanged: (String? newValue) {
                    ref
                        .read(registerFormProvider.notifier)
                        .onRoleChanged(newValue!);
                  },
                  items: <String>['student', 'instructor', 'administrative']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nombre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontFamily: 'PT Sans',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged:
                      ref.read(registerFormProvider.notifier).onNameChanged,
                  enableInteractiveSelection: false,
                  autofocus: true,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    errorText: registerForm.isFormPosted
                        ? registerForm.name.errorMessage
                        : null,
                    filled: true,
                    fillColor: const Color.fromRGBO(52, 54, 70, 100),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: null,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ap. Paterno',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontFamily: 'PT Sans',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onChanged: ref
                            .read(registerFormProvider.notifier)
                            .onPaternalSurnameChanged,
                        enableInteractiveSelection: false,
                        autofocus: true,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          errorText: registerForm.isFormPosted
                              ? registerForm.name.errorMessage
                              : null,
                          filled: true,
                          fillColor: const Color.fromRGBO(52, 54, 70, 100),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ap. Materno',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontFamily: 'PT Sans',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onChanged: ref
                            .read(registerFormProvider.notifier)
                            .onMaternalSurnameChanged,
                        enableInteractiveSelection: false,
                        autofocus: true,
                        onTapOutside: (event) =>
                            FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          errorText: registerForm.isFormPosted
                              ? registerForm.paternalSurname.errorMessage
                              : null,
                          filled: true,
                          fillColor: const Color.fromRGBO(52, 54, 70, 100),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Correo electrónico',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontFamily: 'PT Sans',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged:
                      ref.read(registerFormProvider.notifier).onEmailChange,
                  enableInteractiveSelection: false,
                  autofocus: true,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    errorText: registerForm.isFormPosted
                        ? registerForm.email.errorMessage
                        : null,
                    filled: true,
                    fillColor: const Color.fromRGBO(52, 54, 70, 100),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: null,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontFamily: 'PT Sans',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged:
                      ref.read(registerFormProvider.notifier).onPasswordChanged,
                  enableInteractiveSelection: false,
                  autofocus: true,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  obscureText: true,
                  decoration: InputDecoration(
                    errorText: registerForm.isFormPosted
                        ? registerForm.password.errorMessage
                        : null,
                    filled: true,
                    fillColor: const Color.fromRGBO(52, 54, 70, 100),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: null,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirmar Contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontFamily: 'PT Sans',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onFieldSubmitted: (_) =>
                      ref.read(registerFormProvider.notifier).onFormSubmit(),
                  onChanged: ref
                      .read(registerFormProvider.notifier)
                      .onConfirmPasswordChanged,
                  obscureText: true,
                  enableInteractiveSelection: false,
                  autofocus: true,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    errorText: registerForm.isPasswordsMatch
                        ? null
                        : 'Las contraseñas no coinciden',
                    filled: true,
                    fillColor: const Color.fromRGBO(52, 54, 70, 100),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: null,
                ),
              ],
            ),
            const SizedBox(height: 15),
            authState.isLoading
                ? const CircularProgressIndicator()
                : FilledButton(
                    onPressed: () {
                      ref.read(registerFormProvider.notifier).onFormSubmit();
                    },
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 10),
                      child: Text(
                        'Registrarse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontFamily: 'PT Sans',
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 15),
            const Text(
              '¿Ya tienes una cuenta? Inicia sesión',
              style: TextStyle(color: Colors.white),
            ),
            InkWell(
              onTap: () {
                // Aquí rediriges a la pantalla de inicio de sesión
                GoRouter.of(context).go('/login');
              },
              child: const Text(
                'desde aquí',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
