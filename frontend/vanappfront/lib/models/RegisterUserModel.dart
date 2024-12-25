class RegisterUserModel {
  final String name;
  final String email;
  final String password;
  final double lat;
  final double lng;

  RegisterUserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.lat,
    required this.lng,
  });

  factory RegisterUserModel.fromJson(Map<String, dynamic> map) {
    return RegisterUserModel(
      name: map['name'],
      email: map['email'],
      password: map['password'],
      lat: map['lat'].toDouble(),
      lng: map['lng'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password':password,
      'lat': lat,
      'lng': lng,
    };
  }
}
