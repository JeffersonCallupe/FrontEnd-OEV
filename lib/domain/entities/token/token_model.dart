class Token {
  final int id;
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String email;
  final String phone;
  final String role;
  final String token;

  Token({
    required this.id,
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.email,
    required this.phone,
    required this.role,
    required this.token,
  });

  Token copyWith({
    int? id,
    String? name,
    String? paternalSurname,
    String? maternalSurname,
    String? email,
    String? phone,
    String? role,
    String? token,
  }) {
    return Token(
      id: id ?? this.id,
      name: name ?? this.name,
      paternalSurname: paternalSurname ?? this.paternalSurname,
      maternalSurname: maternalSurname ?? this.maternalSurname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      token: token ?? this.token,
    );
  }
}
