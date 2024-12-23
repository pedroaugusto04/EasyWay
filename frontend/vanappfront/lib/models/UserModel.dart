class UserModel {
  final String id;
  final String name;
  final String email;
  final double lat;
  final double lng;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.lat,
    required this.lng,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      lat: map['lat'].toDouble(),
      lng: map['lng'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'lat': lat,
      'lng': lng,
    };
  }
}
