class ConferenceRequestDTO {
  final String name;
  final String description;
  final String? imageUrl;
  final String? category;
  final DateTime date;

  ConferenceRequestDTO({required this.name, required this.description, this.imageUrl, this.category, required this.date});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl ?? 'https://img.freepik.com/vector-gratis/ilustracion-conferencia-medica_23-2148904006.jpg',
      'category': category,
      'date': date.toIso8601String().split('T').first,
    };
  }
}
