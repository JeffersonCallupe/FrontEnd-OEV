import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/course_dto.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/courses_providers/courses_provider.dart';

final snackbarMessageProvider = StateProvider<String?>((ref) => null);

class CreateCourseScreen extends ConsumerStatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  _CreateCourseScreenState createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends ConsumerState<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _targetAudienceController =
      TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedLevel;
  String? _selectedCategory;

  final List<String> levels = ['Básico', 'Intermedio', 'Avanzado'];

  final List<String> categories = [
    'Tecnología y Programación',
    'Negocios y Emprendimiento',
    'Diseño',
    'Ciencias y Matemáticas',
    'Idiomas',
    'Desarrollo Personal',
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(snackbarMessageProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content:
                    Text(next, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.blueAccent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            )
            .closed
            .then((_) => Navigator.pop(context));
        ref.read(snackbarMessageProvider.notifier).state =
            null; // Limpiar mensaje
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Crear Curso', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E1E2C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(_nameController, 'Título del curso'),
                _buildTextField(_descriptionController, 'Descripción'),
                _buildTextField(_benefitsController, 'Beneficios',
                    required: false),
                _buildTextField(_targetAudienceController, 'Audiencia objetivo',
                    required: false),
                const SizedBox(height: 15),
                _buildDropdownField('Categoría', categories, _selectedCategory,
                    (value) => setState(() => _selectedCategory = value)),
                const SizedBox(height: 30),
                _buildDropdownField('Nivel', levels, _selectedLevel,
                    (value) => setState(() => _selectedLevel = value)),
                const SizedBox(height: 15),
                _buildTextField(_priceController, 'Precio', isNumeric: true),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _createCourse,
                  icon: const Icon(Icons.add),
                  label: const Text('Crear Curso'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> elements,
      String? selectedValue, void Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      dropdownColor: Colors.black54,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: const OutlineInputBorder(),
      ),
      items: elements.map((element) {
        return DropdownMenuItem(
          value: element,
          child: Text(element, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = true,
    bool isNumeric = false,
    int? maxLines, // Permite definir el número máximo de líneas
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        onTapOutside: (event) => FocusScope.of(context).unfocus(),
        minLines: maxLines == null
            ? 1
            : null, // Si no hay `maxLines`, usa una sola línea
        maxLines: maxLines, // Define el número máximo de líneas
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.isEmpty)) {
            return 'Este campo es obligatorio';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _createCourse() async {
    if (!_formKey.currentState!.validate()) return;

    int id = ref.read(authProvider).token?.id ?? 0;
    final newCourse = CourseRequestDTO(
      name: _nameController.text,
      description: _descriptionController.text,
      benefits:
          _benefitsController.text.isNotEmpty ? _benefitsController.text : null,
      targetAudience: _targetAudienceController.text.isNotEmpty
          ? _targetAudienceController.text
          : null,
      category: _selectedCategory,
      level: _selectedLevel,
      price: double.tryParse(_priceController.text) ?? 0.0,
    );

    try {
      await ref.read(addCourseProvider.notifier).addCourse(id, newCourse);
      ref.invalidate(coursesProvider);
      ref.read(snackbarMessageProvider.notifier).state =
          "Curso creado correctamente";
    } catch (e) {
      ref.read(snackbarMessageProvider.notifier).state =
          "Error al crear el curso";
    }
  }
}
