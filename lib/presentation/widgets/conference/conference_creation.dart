import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oev_mobile_app/domain/entities/dto/request/conference_dto.dart';
import 'package:oev_mobile_app/presentation/providers/auth_provider.dart';
import 'package:oev_mobile_app/presentation/providers/conferences_providers/conferences_provider.dart';

final snackbarMessageProvider = StateProvider<String?>((ref) => null);

class CreateConferenceScreen extends ConsumerStatefulWidget {
  const CreateConferenceScreen({super.key});

  @override
  _CreateConferenceScreenState createState() => _CreateConferenceScreenState();
}

class _CreateConferenceScreenState extends ConsumerState<CreateConferenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(); // Agregamos un controlador para la fecha

  String? _selectedCategory;
  DateTime? _selectedDate;

  final List<String> levels = ['Básico', 'Intermedio', 'Avanzado'];

  final List<String> categories = [
    'Innovación y Tecnología',
    'Investigación y Desarrollo Académico',
    'Empleabilidad y Desarrollo Profesional',
    'Ciencia',
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(snackbarMessageProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(next, style: const TextStyle(color: Colors.white)),
                backgroundColor: Colors.blueAccent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 1),
              ),
            )
            .closed
            .then((_) => Navigator.pop(context));
        ref.read(snackbarMessageProvider.notifier).state = null; // Limpiar mensaje
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text('Crear Conferencia', style: TextStyle(color: Colors.white)),
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
                _buildTextField(_nameController, 'Título del Conferencia'),
                _buildTextField(_descriptionController, 'Descripción'),
                const SizedBox(height: 15),
                _buildDropdownField('Categoría', categories, _selectedCategory, (value) => setState(() => _selectedCategory = value)),
                const SizedBox(height: 30),
                TextFormField(
                  readOnly: true,
                  controller: _dateController, // Usamos el controlador persistente
                  decoration: const InputDecoration(
                    labelText: 'Fecha de la Conferencia',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(color: Colors.white), // Aseguramos que el texto sea visible
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _selectedDate) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0]; // Formateamos la fecha
                      });
                    }
                  },
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: _createConference,
                  child: const Text('Crear Conferencia'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> elements, String? selectedValue, void Function(String?) onChanged) {
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
        minLines: maxLines == null ? 1 : null, // Si no hay `maxLines`, usa una sola línea
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

  Future<void> _createConference() async {
    if (!_formKey.currentState!.validate()) return;

    int id = ref.read(authProvider).token?.id ?? 0;
    final newConference = ConferenceRequestDTO(
      name: _nameController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      date: _selectedDate ?? DateTime.now(),
    );

    try {
      await ref.read(addConferenceProvider.notifier).addConference(id, newConference);
      ref.invalidate(conferenceProvider);
      ref.read(snackbarMessageProvider.notifier).state = "Conferencia creado correctamente";
    } catch (e) {
      ref.read(snackbarMessageProvider.notifier).state = "Error al crear el Conferencia";
    }
  }
}
