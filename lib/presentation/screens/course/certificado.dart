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

// --- Tarjeta de Certificado ---
class CertificateCard extends StatelessWidget {
  final String courseName;
  final String lessons;
  final String completed;
  final String students;

  const CertificateCard({
    required this.courseName,
    required this.lessons,
    required this.completed,
    required this.students,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff25253D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 📌 Imagen del certificado desde assets
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/certificado.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[700],
                    child: const Center(
                      child:
                          Icon(Icons.broken_image, color: Colors.red, size: 30),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // 📜 Información del curso
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    courseName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.menu_book, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(lessons,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 8),
                      const Icon(Icons.check_circle,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(completed,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      const SizedBox(width: 8),
                      const Icon(Icons.people, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(students,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // 📥 Botón de descarga
            IconButton(
              icon: const Icon(Icons.download, color: Colors.white, size: 24),
              onPressed: () {
                // Acción al descargar el certificado
              },
            ),
          ],
        ),
      ),
    );
  }
}
