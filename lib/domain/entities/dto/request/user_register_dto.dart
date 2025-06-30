class UserRegisterDto {
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String email;
  final String password;
  final String phone;
  final String role;

  UserRegisterDto({
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });

  static Map<String, dynamic> entityToJson(UserRegisterDto userRegisterDto) {
    return {
      'name': userRegisterDto.name,
      'paternalSurname': userRegisterDto.paternalSurname,
      'maternalSurname': userRegisterDto.maternalSurname,
      'email': userRegisterDto.email,
      'password': userRegisterDto.password,
      'phone': userRegisterDto.phone,
      'role': userRegisterDto.role,
    };
  }

  static UserRegisterDto jsonToEntity(Map<String, dynamic> json) {
    return UserRegisterDto(
      name: json['name'],
      paternalSurname: json['paternalSurname'],
      maternalSurname: json['maternalSurname'],
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      role: json['role'],
    );
  }
}
