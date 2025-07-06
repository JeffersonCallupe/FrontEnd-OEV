import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/login_form_provider.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const String name = 'login_screen';
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondosm.png'), 
            fit: BoxFit.cover, 
          ),
        ),
        child: const _LoginForm(), 
      ),
    );
  }
}




class _LoginForm extends ConsumerWidget {
  const _LoginForm();
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
    final loginForm = ref.watch(loginFormProvider);
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;

      showSnackBar(
        context,
        next.errorMessage,
      );
    });
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 30.0,
        vertical: 15.0,
      ),
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/images/oev_logo.png',
                width: 240,
                height: 90,
              ),
            ),
            const SizedBox(height: 40),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Bienvenido - OEV App',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Open Sans',
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '¡Bienvenido! Completa tus datos para iniciar sesión.',
                style: TextStyle(
                  color: Color(0xFFB0B3C6),
                  fontFamily: 'PT Sans',
                  fontSize: 12.0,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Correo institucional',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontFamily: 'PT Sans',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  onChanged: ref.read(loginFormProvider.notifier).onEmailChange,
                  enableInteractiveSelection: false,
                  autofocus: true,
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    errorText: loginForm.isFormPosted ? loginForm.email.errorMessage : null,
                    filled: true,
                    fillColor: const Color.fromRGBO(52, 54, 70, 100),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  style: const TextStyle(color: Color.fromARGB(106, 255, 255, 255)),
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
                        'Contraseña',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 14.0,
                          fontFamily: 'PT Sans',
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        onFieldSubmitted: (_) => ref.read(loginFormProvider.notifier).onFormSubmit(),
                        onChanged: ref.read(loginFormProvider.notifier).onPasswordChanged,
                        obscureText: true,
                        enableInteractiveSelection: false,
                        autofocus: true,
                        onTapOutside: (event) => FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          errorText: loginForm.isFormPosted ? loginForm.password.errorMessage : null,
                          filled: true,
                          fillColor: const Color.fromRGBO(52, 54, 70, 100),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: null,
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    // Checkbox(
                    //   value: true,
                    //   onChanged: (){},
                    // ),
                    Text(
                      'Recuérdame',
                      style: TextStyle(
                        fontFamily: 'PT Sans',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    // Pendiente la lógica para recuperar contraseña
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      fontFamily: 'PT Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.0,
                      color: Color(0xFF0177FB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loginForm.isPosting ? null : ref.read(loginFormProvider.notifier).onFormSubmit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (loginForm.isPosting)
                      const SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(width: 10.0),
                    const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontFamily: 'PT Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Pendiente la lógica para iniciar sesión con Google
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/google_icon.webp', height: 24.0, width: 24.0),
                    const SizedBox(width: 10.0),
                    const Text(
                      'Iniciar sesión con Google',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontFamily: 'PT Sans',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            InkWell(
              onTap: () {
                context.push('/register');
              },
              child: const Text(
                '¿Aún no tienes una cuenta? Registrarte aquí.',
                style: TextStyle(
                  fontFamily: 'PT Sans',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.0,
                  color: Color(0xFFB8B8B8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}