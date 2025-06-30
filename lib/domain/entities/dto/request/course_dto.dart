class CourseRequestDTO {
  final String name;
  final String description;
  final String? benefits;
  final String? targetAudience;
  final String? imageUrl;
  final String? category;
  final String? level;
  final double? price;

  CourseRequestDTO({required this.name, required this.description, this.benefits, this.targetAudience, this.imageUrl, this.category, this.level, this.price});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'benefits': benefits,
      'targetAudience': targetAudience,
      'imageUrl': imageUrl ?? 'https://www.acacia.edu/wp-content/uploads/2023/06/acacia-blog-image-1024x578.jpg',
      'category': category,
      'level': level,
      'price': price,
    };
  }
}
