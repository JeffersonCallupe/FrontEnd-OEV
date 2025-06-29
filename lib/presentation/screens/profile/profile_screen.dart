import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oev_mobile_app/domain/errors/auth_errors.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  static const String name = 'profile_screen';

  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool isEditing = false;
  bool isLoading = false; // Agregamos esta variable de estado
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController paternalSurnameController;
  late TextEditingController maternalSurnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    final token = ref.read(authProvider).token;
    nameController = TextEditingController(text: token?.name ?? '');
    paternalSurnameController =
        TextEditingController(text: token?.paternalSurname ?? '');
    maternalSurnameController =
        TextEditingController(text: token?.maternalSurname ?? '');
    emailController = TextEditingController(text: token?.email ?? '');
    phoneController = TextEditingController(text: token?.phone ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    paternalSurnameController.dispose();
    maternalSurnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final token = ref.read(authProvider).token;
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'No hay sesión activa. Por favor, vuelve a iniciar sesión.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      setState(() => isLoading = true);
      // Obtener un token válido
      final validToken = await ref.read(authProvider.notifier).getValidToken();

      final userData = {
        'id': token.id,
        'name': nameController.text.trim(),
        'paternalSurname': paternalSurnameController.text.trim(),
        'maternalSurname': maternalSurnameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim()
      };

      print('Sending update request with data: $userData');

      // Pasamos el token.token aquí
      await ref.read(userUpdateProvider.notifier).updateUser(
            token.id,
            userData,
            validToken, // Pasamos el token de autenticación
          );

      final updatedToken = token.copyWith(
        name: nameController.text.trim(),
        paternalSurname: paternalSurnameController.text.trim(),
        maternalSurname: maternalSurnameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );

      await ref.read(authProvider.notifier).updateToken(updatedToken);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          isEditing = false;
          isLoading = false;
        });
      }
    } on NotAuthorizedException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
        // Redirigir al home
        context.go('/home');
      }
    } catch (e) {
      print('Error in _saveChanges: $e');
      if (mounted) {
        if (e.toString().contains('Sesión expirada')) {
          ref
              .read(authProvider.notifier)
              .logout('Sesión expirada. Por favor, vuelve a iniciar sesión.');
          context.go('/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar el perfil: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        setState(() => isLoading = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (isEditing) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xff2a2c3e),
          title: const Text('Cambios sin guardar',
              style: TextStyle(color: Colors.white)),
          content: const Text('¿Deseas guardar los cambios?',
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              child:
                  const Text('Descartar', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            TextButton(
              child:
                  const Text('Guardar', style: TextStyle(color: Colors.blue)),
              onPressed: () async {
                await _saveChanges();
                if (mounted) Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  Future<void> _showPasswordChangeDialog() async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff2a2c3e),
        title: const Text('Change Password',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Change', style: TextStyle(color: Colors.blue)),
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                // Implement password change logic here
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(userUpdateProvider);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xff1a1b26),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                if (context.mounted) context.pop();
              }
            },
          ),
          actions: [
            if (!isEditing)
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => setState(() => isEditing = true),
              ),
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: _saveChanges,
              ),
          ],
          title: const Text('Mi perfil',
              style: TextStyle(color: Colors.white, fontSize: 24)),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person,
                                    size: 50, color: Colors.white),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 18,
                                  child: IconButton(
                                    icon:
                                        const Icon(Icons.camera_alt, size: 18),
                                    onPressed: () {
                                      // Add photo change logic
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // Add photo removal logic
                            },
                            child: const Text('Eliminar foto',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField('Nombre:', nameController, isEditing),
                    _buildTextField('Apellido Paterno:',
                        paternalSurnameController, isEditing),
                    _buildTextField('Apellido Materno:',
                        maternalSurnameController, isEditing),
                    const SizedBox(height: 24),
                    const Text('Datos adicionales',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                      'Llenar estos campos no es obligatorio, sin embargo, te pueden ayudar a personalizar los resultados que muestra la plataforma y aumentar la seguridad de tu cuenta.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                        'Número de teléfono:', phoneController, isEditing),
                    _buildTextField('Correo:', emailController, isEditing),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cambiar contraseña:',
                          style: TextStyle(color: Colors.white70)),
                      trailing: TextButton(
                        onPressed: _showPasswordChangeDialog,
                        child: const Text('Modificar',
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          minimumSize: const Size(200, 45),
                        ),
                        onPressed: () {
                          ref.read(authProvider.notifier).logout();
                        },
                        child: const Text('Cerrar Sesión'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (updateState.isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool enabled,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Este campo es requerido';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? Colors.white : Colors.white70,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          disabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
          ),
          errorStyle: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}