import 'package:flutter/material.dart';

class CertificateScreen extends StatelessWidget {
  const CertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> certificates = [
      {
        "courseName": "Adobe Illustrator desde cero hasta intermedio",
        "lessons": "24",
        "completed": "24",
        "students": "5k"
      },
      {
        "courseName": "Carrera al Éxito: Potencia tu CV",
        "lessons": "30",
        "completed": "30",
        "students": "2k"
      },
      {
        "courseName": "Eleva tu Gestión de TI: COBIT en Acción",
        "lessons": "45",
        "completed": "45",
        "students": "3k"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xff1E1E2C),
      appBar: AppBar(
        backgroundColor: const Color(0xff1E1E2C),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Mis Certificados",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: certificates.length,
          itemBuilder: (context, index) {
            final certificate = certificates[index];

            return CertificateCard(
              courseName: certificate["courseName"]!,
              lessons: certificate["lessons"]!,
              completed: certificate["completed"]!,
              students: certificate["students"]!,
            );
          },
        ),
      ),
    );
  }
}
